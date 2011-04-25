# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
require 'pathname'
require 'shellwords'
include Nanoc3::Helpers::Rendering

module KyotoClient
  def self.version
    path = (Pathname(__FILE__).dirname.parent.parent + 'lib' + 'index.js').realpath.to_s
    `node #{path.shellescape}`.strip
  end
  
end