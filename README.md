
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

If you'd like users to be able to transcribe a field, but don't want that field to be verified (for example, interesting notes), add, for example

  skip_verification :notes, :related_urls

to your master model.

Run the generator, which will create everything you need for transcriptions: a migration based on your master table's transcribable attributes, a transcription model, controller, views and routes.

    rails g transcribable

Then run:

    rake db:migrate

If you ever need to add more transcribable columns, just add them to your master table, add them to the `transcribable` call in your master model, and then rerun `rails g transcribable`. That will generate a new migration for adding the new columns to the transcriptions table.

To populate your master table with documents for users to verify, you can harvest them from a DocumentCloud project. Fill out the `documentcloud.yml` file that was generated for you in your config directory, and run:

    rake transcribable:harvest

Now, you just need a way to assign out files. In the controller that corresponsds to your master table, we'll write a "gimme" method that randomly assigns files to transcribe. You may want to modify this later on to weight assignments by certain factors, but for now we'll do it randomly:

    class FilingsController < ActionController::Base
      def gimme
        @filing = Filing.assign!
        respond_to do |format|
          format.html { 
            redirect_to(new_transcription_path({:filing_id => @filing.id }))
          }
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

**Note**: By default, Transcribable keeps users from transcribing the same document more than once by assigning a UUID-based cookie. Obviously this isn't ideal for rigorous journalistic applications. You'll want to implement a real login system for complicated projects.