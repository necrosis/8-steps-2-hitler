#include <QCoreApplication>
#include <QDir>
#include <QDebug>
#include <QFileInfo>
#include <QStringList>

#include "translatorsmodel.h"


TranslatorsModel::TranslatorsModel(QObject *parent) : QAbstractListModel(parent)
{
    load();
}

TranslatorsModel::~TranslatorsModel()
{
    if (!m_langs.empty())
    {
        beginRemoveRows(QModelIndex(), 0, m_langs.length());

        for (auto &pair: m_langs)
        {
            delete pair.second;
        }
        m_langs.clear();

        endRemoveRows();
    }
}

int TranslatorsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_langs.size();
}

QVariant TranslatorsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    auto pair = m_langs.at(index.row());

    switch (role) {
    case CodeRole:
        return QVariant(pair.first);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TranslatorsModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractListModel::roleNames();
    roles[CodeRole] = "code";

    return roles;
}

void TranslatorsModel::load(const QString& path)
{
    if (!m_langs.empty())
    {
        beginRemoveRows(QModelIndex(), 0, m_langs.length());
        m_langs.clear();
        endRemoveRows();
    }
    m_langs.append(qMakePair(QString("en"), nullptr)); // default language

    auto searchPath = QDir(path);

    QStringList filters;
    filters << "*.qm";
    searchPath.setNameFilters(filters);

    auto filesEntryList = searchPath.entryList();

    if (!filesEntryList.empty())
    {
        auto size = filesEntryList.length();
        beginInsertRows(QModelIndex(), 1, size);

        for (auto &fileEntry: filesEntryList)
        {
            QFileInfo fileInfo(fileEntry);
            auto *translator = new QTranslator();
            if (translator->load(fileInfo.absoluteFilePath()))
            {
                m_langs.append(
                    qMakePair(
                        fileInfo.baseName(),
                        translator
                    )
                );
            }
        }

        endInsertRows();
    }
}

void TranslatorsModel::changeLanguage(const QString& code)
{
    if (code == m_currentLang)
        return;

    auto *app = QCoreApplication::instance();

    if (app == nullptr)
    {
        qDebug() << "Can't reach app";
        return;
    }

    if (code == "en")  // default language - remove translator
    {
        auto currentTranslator = getTranslatorByCode(m_currentLang);
        app->removeTranslator(currentTranslator);
        m_currentLang = code;
        emit reloadTranslations();
        return;
    }

    auto newTranslator = getTranslatorByCode(code);
    if (!newTranslator)
    {
        qDebug() << "Wrong language code";
        return;
    }

    app->installTranslator(newTranslator);
    m_currentLang = code;
    emit reloadTranslations();
}
