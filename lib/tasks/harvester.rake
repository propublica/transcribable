namespace :transcribable do
  desc "Harvest documents to transcribe from DocumentCloud"
  task :harvest => :environment do
    require 'rest-client'
    klass = Kernel.const_get(Transcribable.table.classify)
    dc = YAML.load(File.read("#{Rails.root.to_s}/config/documentcloud.yml"))
    dc_project = JSON.parse(RestClient.get("https://#{CGI::escape(dc['email'])}:#{CGI::escape(dc['password'])}@www.documentcloud.org/api/projects.json"))

    # i had to use this to return the desired project
    # trace came back NoMethodError: undefined method `scan' for 19735:Fixnum
    # running rails 4.2.1
    #dc_project = dc_project['projects'].select {|q| q['id'] == dc['project']}[0]

    dc_project = dc_project['projects'].select {|q| q['id'] == dc['project'].scan(/^\d+/)[0].to_i }[0]


    dc_project['document_ids'].each do |doc_id|
      begin
        dc_doc = JSON.parse(RestClient.get("https://www.documentcloud.org/api/documents/#{doc_id}.json"))['document']
      # this will skip non-public documents
      rescue RestClient::ResourceNotFound
        next
      end

      # uses updated method with model field & value as the argument
      obj = klass.find_or_initialize_by(url: "https://www.documentcloud.org/documents/#{dc_doc['id']}")

      # don't plow over verified docs if rerunning the script
      obj.verified = false if obj.new_record?
      obj.save
      puts "== added #{obj.url}"
    end
  end
end