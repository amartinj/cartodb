module Carto
  class UserTable
    class << self
      # {
      #   "information": {
      #     "name": str,
      #     "description": str,
      #     "timestamp": timestamp
      #     "classification": {
      #       tags: [],
      #       categories: [] ?? (need hierarchies?)
      #     }
      #   },
      #   "data": {
      #     "source": {
      #       "type": str,
      #       "configuration": { Varies based on type }
      #     }
      #   }
      #   "publishing": {
      #     "privacy": str
      #   }
      # }

      def from_metada(metadata)
        user_table = Carto::UserTable.new(metadata)
        visualization = Carto::VisualizationFactory.create_canonical_visualization(user_table)

        if should_sync?
          synchornization = Carto::Synchornization.new
          visualization.synchornization = synchornization
          user_table.map = visualization.map
        end

        user_table
      end
    end
  end
end
