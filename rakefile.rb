$cc = ENV["CC"] || "gcc"
$remote_target = ENV["REMOTE_TARGET"] || "192.168.0.4"
$remote_user = ENV["REMOTE_USER"] || "root"
$home = ENV["HOME"] || "/home/vagrant"

target_plugins = ['gstreamer-plugins-bad']

def get_install_dir(plugin)
  File.join($home, "build", $cc, plugin)
end

def get_build_dir(plugin)
  File.join($home, plugin)
end

def install_remote

end

task :install_base => [:build_base] do
  if $cc == "gcc"
    plugin = "gstreamer"
    install_dir = get_install_dir(plugin)
    sh "mkdir -p /apps/#{plugin}/local"
    sh "cp -r #{install_dir} /apps/#{plugin}/local"
  else
    install_remote
  end
end

def config_base
  build_dir = get_build_dir("gstreamer")
  install_dir = get_install_dir("gstreamer")
  Dir.chdir(build_dir) do
    begin
      cfg = File.open('.config_target', &:readline)
    rescue
      cfg = ""
    end
    if $cc != cfg
      sh "./autogen.sh"
      sh "./configure  --prefix=#{install_dir} --enable-gtk-doc --enable-iso-codes --enable-orc"
      File.write('.config_target', $cc)
    end
  end
end

task :clean_base do
  build_dir = get_build_dir("gstreamer")
  Dir.chdir(build_dir) do
    File.delete('.config_target') if File.exist?('.config_target')
    sh "make clean"
  end
end

task :build_base do
  plugin = "gstreamer"
  install_dir = get_install_dir(plugin)
  build_dir = get_build_dir(plugin)
  sh "mkdir -p #{install_dir}"
  config_base
  Dir.chdir(build_dir) do
    sh "make -j2 install"
  end
end


task :install_modules => [:build_modules] do
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

task :build_modules => [:install_base] do
  target_plugins.each { |plugin|
    install_dir = get_install_dir(plugin)
    autogen = File.join(get_build_dir(plugin), "autogen.sh")
    configure = File.join(get_build_dir(plugin), "configure")
    sh "mkdir -p #{install_dir}"
    sh "module load "
    sh "#{autogen}"
    sh "#{configure}  --prefix=#{install_dir} --enable-gtk-doc --enable-iso-codes --enable-orc"
  }
end
