# make sure all repos are updated before packages everywhere.
Yumrepo <| |> -> Package <| |>

#some repos
class {'::yum::repo::remi':}
class {'::yum::repo::remi_php55':}

#main class
class {'personal':}
