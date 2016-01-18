require "spec_helper"
require "app/models/config/base"
require "app/models/config/jshint"

describe Config::Jshint do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        {
          "maxlen": 80,
        }
      EOS
    end

    let(:hound_config_content) do
      {
        "jshint" => {
          "enabled" => true,
          "config_file" => "config/.jshintrc",
        },
      }
    end
  end

  describe "#excluded_files" do
    context "when no ignore file is configured" do
      it "returns the default paths" do
        commit = stubbed_commit(".jshintignore" => nil)
        config = build_config(commit)

        expect(config.excluded_files).to eq ["vendor/*"]
      end
    end

    context "when an ignore file is configured" do
      it "returns the paths specified in the file" do
        commit = stubbed_commit(
          ".jshintignore" => <<-EOS.strip_heredoc
              app/javascript/vendor/*
          EOS
        )
        config = build_config(commit)

        expect(config.excluded_files).to eq ["app/javascript/vendor/*"]
      end
    end
  end

  def build_config(commit)
    Config::Jshint.new(stubbed_hound_config(commit), "jshint")
  end

  def stubbed_hound_config(commit)
    double(
      "HoundConfig",
      commit: commit,
      content: {
        "javascript" => {
          "enabled" => true,
          "config_file" => "config/jshint.json",
        },
      },
    )
  end
end