task :default do
  sh "gcc main.c -o gst_test -lgstapp-1.0 $(pkg-config --cflags --libs gstreamer-1.0)"
end
