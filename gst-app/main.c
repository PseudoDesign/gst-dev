#include <gst/gst.h>
#include <glib.h>
#include "default_klv.h"
#include <gst/app/gstappsrc.h>
#include <stdio.h>



static void prepare_buffer(GstAppSrc* appsrc) {
  GstFlowReturn ret;
  static GstClockTime timestamp = 0;

  GstBuffer *buffer = gst_buffer_new_wrapped_full( 0, (gpointer)default_klv, sizeof(default_klv), 0, sizeof(default_klv), NULL, NULL );

  ret = gst_app_src_push_buffer(appsrc, buffer);

  if (ret != GST_FLOW_OK) {
    /* something wrong, stop pushing */
    g_print("Something went wrong");
  }
}

static void klv_need_data (GstElement *appsrc, guint unused_size, gpointer user_data) {
  g_print("In need-data \n");
  prepare_buffer((GstAppSrc*)appsrc);
}

int
main (int   argc,
      char *argv[])
{

  GstElement *pipeline, *sink, *ts_mux;
  GstElement *source;
  GstCaps *klv_cap;

  gst_init (&argc, &argv);

  GMainLoop *loop = g_main_loop_new(NULL, FALSE);
  pipeline = gst_pipeline_new("gcs_default");

  klv_cap = gst_caps_new_simple ("meta/x-klv", NULL, NULL);

  source = gst_element_factory_make("appsrc", "fake-src");

  ts_mux = gst_element_factory_make("mpegtsmux", "tsmux");

  sink = gst_element_factory_make("filesink", "sink");
  g_object_set(G_OBJECT(sink), "location", "test.ts", NULL);

  gst_bin_add_many (GST_BIN(pipeline), source, sink, ts_mux, NULL);

  gst_element_link_many(ts_mux, sink, NULL);

  g_object_set (G_OBJECT (source),
		"stream-type", 0, // GST_APP_STREAM_TYPE_STREAM
		"format", GST_FORMAT_TIME,
    "is-live", TRUE,
    NULL);
  g_signal_connect (source, "need-data", G_CALLBACK (klv_need_data), NULL);

  gst_element_link_pads_filtered (source,
                              "src",
                              ts_mux,
                              "sink_144",
                              klv_cap);

  prepare_buffer((GstAppSrc*)source);

  g_print("Starting default pipeline");
  gst_element_set_state (pipeline, GST_STATE_PLAYING);

  g_main_loop_run (loop);
}
