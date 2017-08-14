$cc = ENV["CC"] || "gcc"
$remote_target = ENV["REMOTE_TARGET"] || "192.168.0.4"
$remote_user = ENV["REMOTE_USER"] || "root"
$home = ENV["HOME"] || "/home/vagrant"

target_plugins = ['gstreamer', 'gstreamer-plugins-bad']

def get_install_dir(plugin)
  File.join($home, "build", $cc, plugin)
end

def install_remote

end

task :install => [:build] do
  if $cc == "gcc"
    target_plugins.each { |plugin|
      install_dir = get_install_dir(plugin)
      sh "mkdir -p /apps/#{plugin}/local"
      sh "cp -r #{install_dir} /apps/#{plugin}/local"
    }
  else
    install_remote
  end
end

task :build do
  target_plugins.each { |plugin|
    install_dir = get_install_dir(plugin)
    sh "mkdir -p #{install_dir}"
  }
end
