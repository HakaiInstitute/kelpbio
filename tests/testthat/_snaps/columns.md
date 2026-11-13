# doc_data_columns lists the required and optional columns

    Code
      cat(doc_data_columns("size_census_nereo"))
    Output
      Required columns:
      
      - `survey_id`, the survey the plant was counted in (a survey_id of the in situ data).
      - `diameter_mm`, the plant diameter, measured as in the weight data (mm, > 0).
      
      Optional columns:
      
      - `partial`, whether the plant counts as half, such as a plant on the edge of a transect (TRUE or FALSE).

