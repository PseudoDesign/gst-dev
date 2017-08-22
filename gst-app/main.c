#include <gst/gst.h>
#include <glib.h>
#include "default_klv.h"
#include <gst/app/gstappsrc.h>
#include <stdio.h>


int
main (int   argc,
      char *argv[])
{

  GstElement *pipeline, *sink, *jpegdec, *jpegenc;
  GstElement *source;

  gst_init (&argc, &argv);

  GMainLoop *loop = g_main_loop_new(NULL, FALSE);
  pipeline = gst_pipeline_new("gcs_default");

  source = gst_element_factory_make("filesrc", "fake-src");
  g_object_set(G_OBJECT(source), "location", "/share/jaypeg.jpg", NULL);

  jpegdec = gst_element_factory_make("jpegdec", "jpg_decoder");

  jpegenc = gst_element_factory_make("jpegenc", "jpg_encoder");

  sink = gst_element_factory_make("filesink", "sink");

  gst_bin_add_many (GST_BIN(pipeline), source, sink, jpegenc, jpegdec, NULL);

  gst_element_link_many(source, jpegdec, jpegenc, sink, NULL);

  g_print("Starting default pipeline");
  gst_element_set_state (pipeline, GST_STATE_PLAYING);

  g_main_loop_run (loop);
}
