require_relative 'institution'

class ResearchCenter < Institution
  attr_accessor :searched_competences
  property :structure_type,    String
  property :project,          String
  property :initials, String
  property :unit, String
  has n, :research_fields, :through => Resource
  has n, :research_areas, :through => Resource
end
