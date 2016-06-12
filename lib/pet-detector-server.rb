require 'base64'
require 'grape'
require 'pet-detector'
require 'tempfile'

module PetDetectorServer
  class V1 < Grape::API
    include PetDetector

    version 'v1', using: :path
    format :json

    params do
      requires :image, {
        type: String,
        desc: 'A PNG screenshot of the game to solve, encoded in base64.'
      }

      requires :level, {
        type: Integer,
        desc: 'The game level.'
      }

      requires :gas, {
        type: Integer,
        desc: 'The amount of gas the car has.'
      }
    end

    helpers do
      def entity_str(entity)
        if entity.pet? || entity.house? || entity.car?
          entity.to_s
        end
      end
    end

    post :detect do
      begin
        level = Level.get(params[:level])
        file = Tempfile.open('game_image')
        file.binmode
        file.write(Base64.decode64(params[:image]))
        file.flush
        file.close
        bmp = Bitmap.load(file.path)
        file.unlink
        det = BoundaryDetector.new(bmp)
        rect = det.get_bounds
        grid = Grid.new(bmp, rect, level)
        entity_matrix = EntityDetector.new(grid, level.animals).entities
        solver = Solver.new(entity_matrix, params[:gas])

        {
          data: {
            level: params[:level],
            gas: params[:gas],
            solution: solver.solve,
            entities: entity_matrix.map do |x, y, entity|
              {
                name: entity_str(entity),
                track: {
                  top: entity.directions.top?,
                  bottom: entity.directions.bottom?,
                  left: entity.directions.left?,
                  right: entity.directions.right?
                }
              }
            end.rows
          }
        }
      rescue => e
        error!([{ error: e.message }], 500)
      end
    end
  end
end
