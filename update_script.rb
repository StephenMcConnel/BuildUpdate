class BuildUpdateScript
  attr_accessor :header_lines, :options, :lines, :path, :root, :actions, :version
  def initialize(path)
    type = path.split('.')[-1]
    @actions = ScriptActions.create(type)
    @path = path
    @header_lines = []
    @options = {}
    @lines = []
    @root = ''
    @version = @actions.comment('$Id$')
    if File.exist?(path)
      f = File.open(@path, 'r')
      line = f.gets.chomp
      raise "Invalid Header: #{line}\nShould be: #{@actions.file_header}" unless line == @actions.file_header
      while line = f.gets
        variable = @actions.parse_variable(line)
        break if variable.nil?
        @header_lines.push(line)
        @options.merge!(variable)
      end
    end
  end

  def set_header(server, project, build, build_type, root_dir)
    @header_lines = [
        @actions.file_header,
        @actions.variable('server', server)
    ]
    if project.nil? && build.nil?
      @header_lines.push(@actions.variable('build_type',build_type))
    else
      @header_lines.push(@actions.variable('project',project))
      @header_lines.push(@actions.variable('build', build))
    end
    @header_lines.push(@actions.variable('root_dir', root_dir)) unless root_dir.nil?
  end

  def update
    File.open(@path, 'w') do |f|
      f.puts(@header_lines)
      f.puts(@version)
      f.puts(@actions.begin_lines)
      f.puts(@lines)
      f.puts(@actions.end_lines)
    end
  end
end