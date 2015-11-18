module Stratiform
  # Common utilities for file content.
  module File
    # Read in the contents of a file.
    def file_content(filename)
      IO.read(filename)
    end
  end
end
