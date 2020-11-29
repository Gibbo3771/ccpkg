module Jekyll
  module Commands
    class DownloadMasterfile < Command
      class << self
        def init_with_program(prog)
          prog.command([:masterfile]) do |c|
            c.action do |args, options|
              Jekyll.logger.info "TODO download masterfile!"
            end
          end
        end
      end
    end
  end
end