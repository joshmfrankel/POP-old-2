require 'elasticsearch/model'

class Journal < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english', index_options: 'offsets'
    end
  end

  has_and_belongs_to_many :methodologies

  validates :title, presence: true
  validates :editor, presence: true
  validates :impact_factor, numericality: { only_integer: true }

  def self.search(query)
    __elasticsearch__.search(
      query: {
        multi_match: {
          query: query,
          fields: ['title'],
          fuzziness: 'AUTO'
        }
      },
      highlight: {
        pre_tags: ['<em>'],
        post_tags: ['</em>'],
        fields: {
          title: {}
        }
      }
    )
  end
end

# Delete the previous articles index in Elasticsearch
Journal.__elasticsearch__.client.indices.delete index: Journal.index_name rescue nil

# Create the new index with the new mapping
Journal.__elasticsearch__.client.indices.create \
  index: Journal.index_name,
  body: { settings: Journal.settings.to_hash, mappings: Journal.mappings.to_hash }

Journal.import force: true

