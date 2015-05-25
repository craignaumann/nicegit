require 'httparty'

module NiceGit

  class NiceGit

    def self.git_status
      return %x(git status)
    end

    def self.is_git_repo?
      return !git_status.empty?
    end

    def self.init_git_repo
      %x(git init)
    end

    def self.check_and_init
      is_git = self.is_git_repo?
      if !is_git
        p "Initializing git repository"
        self.init_git_repo()
      end
    end

    def self.commit_all_with_message(message)
      %x(git add -A)
      return %x(git commit -am "#{message}")
    end

    def self.ammend_last_commit_date(new_date)
      return %x(GIT_COMMITTER_DATE="#{new_date}" git commit --amend --date "#{new_date}" --no-edit)
    end

    def self.days_ago(days)
      return Time.now - (60*60*24*days)
    end

    def self.days_ahead(days)
      return Time.now + (60*60*24*days)
    end

    def self.format_time_for_commit(date)
      return date.strftime("%a %b %d %H:%M %Y %z")
    end

    ##
    # Gets a random joke from the chuck norris joke api:
    # https://api.chucknorris.io/jokes/random
    #
    def self.get_new_file_contents
      res = HTTParty.get('https://api.chucknorris.io/jokes/random')
      body = res ? res.body : nil

      if body
        begin
          json = JSON.parse(body)
          if json && json["value"]
            return json["value"]
          end
        rescue JSON::ParserError => e
        end
      end

      #If we made it down here, something didn't go correct, just make a random string
      return (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    end

    def self.write_new_contents_to_changelog
      return File::write('changelog.txt', "#{NiceGit::get_new_file_contents()}\n", File.size('changelog.txt'), mode: 'a')
    end

    ##
    # The bang just for drama!
    #
    def self.spoof_the_repo!(max_commits, days_back=365, days_ahead=365)
      puts "Spoofing!"

      #init the repo with our first commit
      puts "Doing initial commit"
      puts self.check_and_init()
      puts self.commit_all_with_message("Initial commit")
      puts self.ammend_last_commit_date(self.days_ago(days_back))

      days_total = days_back + days_ahead
      commit_counter = 2
      0.upto(days_total) do |day_index|
        puts "On day ##{day_index} of #{days_total}"
        commits_for_today = Random.rand(max_commits+1)
        0.upto(commits_for_today) do |commit_number|
          puts "Commit #{commit_number} of #{commits_for_today} for today."
          self.write_new_contents_to_changelog
          self.commit_all_with_message("Commit ##{commit_counter}")
          self.ammend_last_commit_date(self.days_ago(days_back-day_index))
          commit_counter += 1
        end
      end
    end

  end

  p NiceGit.spoof_the_repo!(5)

end