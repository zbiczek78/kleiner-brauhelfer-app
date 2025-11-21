#include "qmlutils.h"
#ifdef Q_OS_ANDROID
  #include <QCoreApplication>
#else
  #include <QDir>
#endif

QString QmlUtils::toLocalFile(const QUrl &url)
{
  #ifdef Q_OS_ANDROID
    QJniObject uri = QJniObject::callStaticObjectMethod(
        "android/net/Uri",
        "parse",
        "(Ljava/lang/String;)Landroid/net/Uri;",
        QJniObject::fromString(url.toString()).object<jstring>());
    return QJniObject::callStaticObjectMethod(
        "org/kleinerbrauhelfer/app/PathUtil",
        "getPath",
        "(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;",
        QNativeInterface::QAndroidApplication::context().object<jobject>(),
        uri.object<jobject>()).toString();
  #else
    return QDir::toNativeSeparators(url.toLocalFile());
  #endif
}

QColor QmlUtils::toColor(unsigned int rgb)
{
    return QColor(rgb);
}
