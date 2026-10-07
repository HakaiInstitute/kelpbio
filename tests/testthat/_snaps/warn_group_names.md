# a site or year with a comma or bracket warns, naming the values

    Code
      warn_group_names(data.frame(site = c("North Reef, inner", "b",
        "North Reef, inner"), year = "2020"), "`d`")
    Condition
      Warning:
      Column `site` of `d` has value "North Reef, inner" containing a comma or square bracket.
      i Parameter names such as `bSiteYear[<site>,<year>]` built from such values cannot be split back into their levels by tools that parse them.

