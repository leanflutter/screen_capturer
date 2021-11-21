#include "include/screen_capturer/screen_capturer_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <atlimage.h>
#include <codecvt>
#include <fstream>
#include <map>
#include <memory>
#include <sstream>

namespace
{

class ScreenCapturerPlugin : public flutter::Plugin
{
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    ScreenCapturerPlugin();

    virtual ~ScreenCapturerPlugin();

  private:
    void ScreenCapturerPlugin::SaveClipboardImageAsPngFile(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void ScreenCapturerPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
{
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "screen_capturer", &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<ScreenCapturerPlugin>();

    channel->SetMethodCallHandler([plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
    });

    registrar->AddPlugin(std::move(plugin));
}

ScreenCapturerPlugin::ScreenCapturerPlugin()
{
}

ScreenCapturerPlugin::~ScreenCapturerPlugin()
{
}

void ScreenCapturerPlugin::SaveClipboardImageAsPngFile(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());

    std::string imagePath = std::get<std::string>(args.at(flutter::EncodableValue("imagePath")));

    flutter::EncodableMap resultMap = flutter::EncodableMap();
    HBITMAP bitmap = NULL;

    OpenClipboard(nullptr);
    bitmap = (HBITMAP)GetClipboardData(CF_BITMAP);
    CloseClipboard();

    if (bitmap != NULL)
    {
        std::vector<BYTE> buf;
        IStream *stream = NULL;
        CreateStreamOnHGlobal(0, TRUE, &stream);
        CImage image;
        ULARGE_INTEGER liSize;

        // screenshot to png and save to stream
        image.Attach(bitmap);
        image.Save(stream, Gdiplus::ImageFormatPNG);
        IStream_Size(stream, &liSize);
        DWORD len = liSize.LowPart;
        IStream_Reset(stream);
        buf.resize(len);
        IStream_Read(stream, &buf[0], len);
        stream->Release();

        // put the imapge in the file
        std::fstream fi;
        fi.open(imagePath, std::fstream::binary | std::fstream::out);
        fi.write(reinterpret_cast<const char *>(&buf[0]), buf.size() * sizeof(BYTE));
        fi.close();

        resultMap[flutter::EncodableValue("imagePath")] = flutter::EncodableValue(imagePath.c_str());
    }

    result->Success(flutter::EncodableValue(resultMap));
}
void ScreenCapturerPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    if (method_call.method_name().compare("saveClipboardImageAsPngFile") == 0)
    {
        SaveClipboardImageAsPngFile(method_call, std::move(result));
    }
    else
    {
        result->NotImplemented();
    }
}

} // namespace

void ScreenCapturerPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar)
{
    ScreenCapturerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
