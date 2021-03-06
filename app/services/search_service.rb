class SearchService

  def find_by_competence competence_name
    @competences = Competence.all(conditions: ["lower(unaccent(name)) like lower(unaccent(?))", competence_name])
  end

  def find_related_competence_institutions compenteces, institution_type
    if institution_type == :company
      institution_discriminator = 'Company'
    else
      institution_discriminator = 'ResearchCenter'
    end
    institutions = Institution.all(fields: [:id], conditions: ["type = ?",institution_discriminator])
    institution_ids = institutions.map { |institution| institution.id }
    competences_id = compenteces.map { |c| c.id }
    @company_competence = CompetenceInstitution.all(conditions: ["competence_id in ? AND (competence_value >= 3 OR competence_value < 0) AND institution_id in ?", competences_id,institution_ids])
  end

  def find_by_segment segment_name
    @segments = Segment.all(conditions: ["lower(unaccent(name)) like lower(unaccent(?))", segment_name])
  end

  def find_related_segment segments, institution_type
    if institution_type == :company
      institution_discriminator = 'Company'
    else
      institution_discriminator = 'ResearchCenter'
    end
    institutions = Institution.all(fields: [:id], conditions: ["type = ?",institution_discriminator])
    institution_ids = institutions.map { |institution| institution.id }
    segments_ids = segments.map { |segment| segment.id }
    return InstitutionSegment.all(conditions: ["segment_id in ? AND institution_id in ?",segments_ids, institution_ids])
  end

  def find_by_company companies
    @companies = Company.all(conditions: ["lower(unaccent(name)) like lower(unaccent(?))", companies])
  end

  def find_by_research_center research_centers
    @research_center = ResearchCenter.all(conditions: ["lower(unaccent(name)) like lower(unaccent(?))", research_centers])
  end

end
