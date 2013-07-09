
     _                                 _ _           _     _      
    | |_ _ __ __ _ _ __  ___  ___ _ __(_) |__   __ _| |__ | | ___ 
    | __| '__/ _` | '_ \/ __|/ __| '__| | '_ \ / _` | '_ \| |/ _ \
    | |_| | | (_| | | | \__ \ (__| |  | | |_) | (_| | |_) | |  __/
     \__|_|  \__,_|_| |_|___/\___|_|  |_|_.__/ \__,_|_.__/|_|\___|
                                                                  
             Drop in crowdsourcing for your Rails app.
                                -*-


To install, add

    gem 'transcribable'

to your Gemfile.

Transcribable will add a `transcribable` method your models. In your "master" table, (of items you'd like verified) specify which attributes you would like users to be able to transcribe, and define the one-to-many relationship like so:

    class Filing < ActiveRecord::Base
      transcribable :buyer, :amount
      has_many :transcriptions
    end

Make sure your master table also has `url` (string) and `verified` (boolean) columns.

Run the generator, which will create everything you need for transcriptions: a migration based on your master table's transcribable attributes, a transcription model, controller, views and routes.

    rails g transcribable

Then run:

    rake db:migrate

To populate your master table with documents for users to verify, you can harvest them from a DocumentCloud project. Fill out the `documentcloud.yml` file that was generated for you in your config directory, and run:

    rake transcribable:harvest

Now, you just need a way to assign out files. In the controller that corresponsds to your master table, we'll write a "gimme" method that randomly assigns files to transcribe. You may want to modify this later on to weight assignments by certain factors, but for now we'll do it randomly:

    class FilingsController < ActionController::Base
      def gimme
        @filing = Filing.assign!
        respond_to do |format|
          format.html { redirect_to(new_transcription_path(@filing))}
        end
      end
    end

You can overwrite the `assign!` method in your master table's model.

Now, to get the `gimme` action working, write a route for it:

    resources :filings, :only => [:index, :show] do
      collection do
        get "gimme"
      end
    end

Start up your app and navigate to http://localhost:3000/filings/gimme. You should be given a random filing from your DocumentCloud harvest.

**Next steps:**

This gives you a bare bones approximation of how a project like [Free the Files](https://projects.propublica.org/free-the-files/) works. Ideally, you should implement a login system so users only get to see filings once (and prevent abuse), and weight assigned filings such that the ones that are about to be verified are given out first, to push them over the top. Since these are implementation-specific decisions, we have chosen not to add them to Transcribable.