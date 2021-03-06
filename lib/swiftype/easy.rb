require 'swiftype/document'

module Swiftype
  class Easy
    include Swiftype::Connection
    include Swiftype::Search

    def initialize(options={})
    end

    module Engine
      def engines
        test_search_module
        get("engines.json")
      end
      def create_engine(engine={})
        post("engines.json", :engine => engine)
      end
      def destroy_engine(engine_id)
        delete("engines/#{engine_id}")
      end
      def suggest(engine_id, query, options={})
        search_params = { :q => query }.merge(parse_suggest_options(options))
        response = post("engines/#{engine_id}/suggest.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records.map { |d| Swiftype::Document.new(d) }}
        results
      end
      def search(engine_id, query, options={})
        search_params = { :q => query }.merge(parse_search_options(options))
        response = post("engines/#{engine_id}/search.json", search_params)
        results = {}
        response['records'].each { |document_type, records| results[document_type] = records.map { |d| Swiftype::Document.new(d) }}
        results
      end
    end

    module DocumentType
      def document_types(engine_id)
        get("engines/#{engine_id}/document_types.json")
      end
      def create_document_type(engine_id, document_type={})
        post("engines/#{engine_id}/document_types.json", :document_type => document_type)
      end
      def destroy_document_type(engine_id, document_type_id)
        delete("engines/#{engine_id}/document_types/#{document_type_id}")
      end
    end

    module Document
      def documents(engine_id, document_type_id)
        get("engines/#{engine_id}/document_types/#{document_type_id}/documents.json")
      end
      def create_document(engine_id, document_type_id, document={})
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents.json", :document => document)
      end
      def create_documents(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_create.json", :documents => documents)
      end
      def destroy_document(engine_id, document_type_id, document_id)
        delete("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}")
      end
      def destroy_documents(engine_id, document_type_id, document_ids=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_destroy.json", :documents => document_ids)
      end
      def create_or_update_document(engine_id, document_type_id, document={})
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/create_or_update.json", :document => document)
      end
      def create_or_update_documents(engine_id, document_type_id, documents=[])
        post("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_create_or_update.json", :documents => documents)
      end
      def update_document(engine_id, document_type_id, document_id, fields)
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/#{document_id}/update_fields.json", { :fields => fields })
      end
      def update_documents(engine_id, document_type_id, documents={})
        put("engines/#{engine_id}/document_types/#{document_type_id}/documents/bulk_update.json", { :documents => documents })
      end
    end

    include Swiftype::Easy::Engine
    include Swiftype::Easy::DocumentType
    include Swiftype::Easy::Document
  end
end
