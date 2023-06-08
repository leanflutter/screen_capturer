#include "include/screen_capturer/screen_capturer_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define SCREEN_CAPTURER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), screen_capturer_plugin_get_type(), \
                              ScreenCapturerPlugin))

struct _ScreenCapturerPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(ScreenCapturerPlugin, screen_capturer_plugin, g_object_get_type())

static void clipboard_request_image_callback(GtkClipboard* clipboard,
                                             GdkPixbuf* pixbuf,
                                             gpointer user_data) {
  g_autoptr(FlMethodCall) method_call = static_cast<FlMethodCall*>(user_data);

  if (!pixbuf) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  gchar* buffer = nullptr;
  gsize buffer_size = 0;
  GError* error = nullptr;

  gdk_pixbuf_save_to_buffer(pixbuf, &buffer, &buffer_size, "png", &error,
                            nullptr);
  if (error) {
    fl_method_call_respond_error(method_call, "0", error->message, nullptr,
                                 nullptr);
    return;
  }

  if (!buffer) {
    fl_method_call_respond_error(method_call, "0", "failed to get image",
                                 nullptr, nullptr);
    return;
  }

  fl_method_call_respond_success(
      method_call,
      fl_value_new_uint8_list(reinterpret_cast<const uint8_t*>(buffer),
                              buffer_size),
      nullptr);
}

static void read_image_from_clipboard(FlMethodCall* method_call) {
  auto* clipboard = gtk_clipboard_get_default(gdk_display_get_default());
  gtk_clipboard_request_image(clipboard, clipboard_request_image_callback,
                              g_object_ref(method_call));
}

// Called when a method call is received from Flutter.
static void screen_capturer_plugin_handle_method_call(
    ScreenCapturerPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "readImageFromClipboard") == 0) {
    read_image_from_clipboard(method_call);
    return;
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void screen_capturer_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(screen_capturer_plugin_parent_class)->dispose(object);
}

static void screen_capturer_plugin_class_init(
    ScreenCapturerPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = screen_capturer_plugin_dispose;
}

static void screen_capturer_plugin_init(ScreenCapturerPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  ScreenCapturerPlugin* plugin = SCREEN_CAPTURER_PLUGIN(user_data);
  screen_capturer_plugin_handle_method_call(plugin, method_call);
}

void screen_capturer_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  ScreenCapturerPlugin* plugin = SCREEN_CAPTURER_PLUGIN(
      g_object_new(screen_capturer_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "screen_capturer", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
