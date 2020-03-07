/*
 * Translator's model
*/
#ifndef TRANSLATORSMODEL_H
#define TRANSLATORSMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QPair>
#include <QTranslator>

class TranslatorsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString selectedLanguage READ selectedLanguage WRITE setSelectedLanguage)
public:
    enum ROLES {
        CodeRole = Qt::UserRole + 1,
    };

    explicit TranslatorsModel(QObject *parent = nullptr);
    virtual ~TranslatorsModel();

    // overrided model's access methods
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    // loads all .qm files from dirpath
    void load(const QString& path = ".");

    // SelectedLanguage's methods
    const QString& selectedLanguage() const { return m_currentLang; }
    void setSelectedLanguage(const QString& val) { changeLanguage(val); }

    // changes language
    Q_INVOKABLE void changeLanguage(const QString& code);

signals:
    // signal for QQmlEngine.retranslate() slot
    void reloadTranslations();

private:
    // Searches a translator by code
    inline QTranslator* getTranslatorByCode(const QString& code) const
    {
        for (auto &pair: m_langs)
        {
            if (pair.first == code)
                return pair.second;
        }

        return nullptr;
    }

private:
    QList<QPair<QString, QTranslator*>> m_langs;
    QString m_currentLang = "en";
};

#endif // TRANSLATORSMODEL_H
