#include "syncservicelocal.h"
#include <QFile>
#ifdef Q_OS_ANDROID
  #include <QtCore/private/qandroidextras_p.h>
#endif

SyncServiceLocal::SyncServiceLocal(QSettings *settings) :
    SyncService(settings)
{
    setFilePath(_settings->value("SyncService/local/DatabasePath").toString());
}

SyncServiceLocal::SyncServiceLocal(const QString &filePath) :
    SyncService(nullptr)
{
    setFilePath(filePath);
}

bool SyncServiceLocal::synchronize(SyncDirection direction)
{
  #ifdef Q_OS_ANDROID
    // check permissions
    if (QtAndroidPrivate::androidSdkVersion() < 29)
    {
        if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.READ_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
            QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.READ_EXTERNAL_STORAGE")).result();
        if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.WRITE_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
            QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.WRITE_EXTERNAL_STORAGE")).result();
    }
    else
    {
        if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.MANAGE_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
            QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.MANAGE_EXTERNAL_STORAGE")).result();
        if(!QJniObject::callStaticMethod<jboolean>("android/os/Environment", "isExternalStorageManager"))
        {
            QJniObject filepermit = QJniObject::getStaticObjectField("android/provider/Settings", "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION", "Ljava/lang/String;");
            QJniObject pkgName = QJniObject::fromString(QStringLiteral("package:org.kleinerbrauhelfer.app"));
            QJniObject parsedUri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", pkgName.object<jstring>());
            QJniObject intent("android/content/Intent", "(Ljava/lang/String;Landroid/net/Uri;)V", filepermit.object<jstring>(), parsedUri.object());
            QtAndroidPrivate::startActivity(intent, 0);
        }
    }
  #endif
    if (QFile::exists(getFilePath()))
    {
        if (direction == SyncDirection::Download)
            setState(SyncState::UpToDate);
        else
            setState(SyncState::Updated);
        return true;
    }
    else
    {
        setState(SyncState::NotFound);
        return false;
    }
}

QString SyncServiceLocal::filePathLocal() const
{
    return getFilePath();
}

void SyncServiceLocal::setFilePathLocal(const QString &filePath)
{
    if (filePathLocal() != filePath)
    {
        setFilePath(filePath);
        if (_settings)
            _settings->setValue("SyncService/local/DatabasePath", filePath);
        emit filePathLocalChanged(filePath);
    }
}
