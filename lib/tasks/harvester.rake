namespace :transcribable do
  desc "Harvest documents to transcribe from DocumentCloud"
  task :harvest => :environment do
    require 'rest-client'
    klass = Kernel.const_get(Transcribable.table.classify)
    dc = YAML.load(File.read("#{Rails.root.to_s}/config/documentcloud.yml"))
    dc_project = JSON.parse(RestClient.get("https://#{CGI::escape(dc['email'])}:#{CGI::escape(dc['password'])}@www.documentcloud.org/api/projects.json"))
    dc_project = dc_project['projects'].select {|q| q['id'] == dc['project'].scan(/^\d+/)[0].to_i }[0]
    dc_project['document_ids'].each do |doc_id|
      begin
        dc_doc = JSON.parse(RestClient.get("https://www.documentcloud.org/api/documents/#{doc_id}.json"))['document']
      rescue RestClient::ResourceNotFound
        next
      end
      obj = klass.find_or_initialize_by_url("https://www.documentcloud.org/documents/#{dc_doc['id']}")
      obj.verified = false if obj.new_record?
      obj.save
      puts "== added #{obj.url}"
    end
  end
end