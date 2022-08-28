## code to prepare `gg_info` dataset goes here


library(magrittr)



# download wikipedia table ------------------------------------------------

wikitable_raw <-
  rvest::read_html("https://en.wikipedia.org/wiki/List_of_Gilmore_Girls_episodes") %>%
  rvest::html_nodes('table[class="wikitable plainrowheaders wikiepisodetable"]') %>%
  rvest::html_table() %>%
  purrr::map2(
    seq_len(7),
    ~ dplyr::select(
      .x,
      index = `No.overall`,
      episode = `No. inseason`,
      title = Title,
      directed_by = `Directed by`,
      written_by = `Written by`,
      air_date = `Original air date`,
      us_views_millions = `US viewers(millions)`
    ) %>%
      dplyr::mutate(season = .y)
  ) %>%
  dplyr::bind_rows()



# split_episode <- function(x) {
#   x <- as.character(x)
#   if (nchar(x) == 4) {
#     return(paste(substr(x, 1, 2), substr(x, 3, 4)))
#   }
#   x
# }



# download imdb ratings ---------------------------------------------------

imdb_rating <- function(x) {
  rating <-
    rvest::read_html(glue::glue(
      "https://www.imdb.com/title/tt0238784/episodes?season={x}"
    )) %>%
    rvest::html_nodes(
      'div[class="list detail eplist"]
       div[class="ipl-rating-star small"]
       span[class="ipl-rating-star__rating"]'
    ) %>%
    rvest::html_text() %>%
    as.numeric()


  tibble::tibble(
    season = x,
    episode = seq_along(rating),
    imdb_rating = rating
  )

}



imdb_ratings_raw <- purrr::map_dfr(seq_len(7), imdb_rating) %>%
  ## remove first line 'Unaired Pilot'
  dplyr::slice(-1)



imdb_ratings_season_1 <- imdb_ratings_raw %>%
  dplyr::filter(season == 1) %>%
  dplyr::mutate(
    episode = dplyr::case_when(
      episode == 2 ~ 1,
      episode == 3 ~ 2,
      episode == 4 ~ 3,
      episode == 5 ~ 4,
      episode == 6 ~ 5,
      episode == 7 ~ 6,
      episode == 8 ~ 7,
      episode == 9 ~ 8,
      episode == 10 ~ 9,
      episode == 11 ~ 10,
      episode == 12 ~ 11,
      episode == 13 ~ 12,
      episode == 14 ~ 13,
      episode == 15 ~ 14,
      episode == 16 ~ 15,
      episode == 17 ~ 16,
      episode == 18 ~ 17,
      episode == 19 ~ 18,
      episode == 20 ~ 19,
      episode == 21 ~ 20,
      episode == 22 ~ 21,
    )
  )



imdb_ratings_season_2_to_7 <- imdb_ratings_raw %>%
  dplyr::filter(season != 1)



imdb_ratings <- imdb_ratings_season_1 %>%
  dplyr::bind_rows(imdb_ratings_season_2_to_7) %>%
  ## create column index
  dplyr::mutate(index = 1:153) %>%
  dplyr::select(-c(season, episode))



# download imdb description -----------------------------------------------

imdb_description <- function(x) {
  description <-
    rvest::read_html(glue::glue(
      "https://www.imdb.com/title/tt0238784/episodes?season={x}"
    )) %>%
    rvest::html_nodes('div[class="item_description"]') %>%
    rvest::html_text()


  tibble::tibble(
    season = x,
    episode = seq_along(description),
    description = description
  )

}



imdb_descriptions_raw <- purrr::map_dfr(seq_len(7), imdb_description) %>%
  ## remove first line 'Unaired Pilot'
  dplyr::slice(-1)



imdb_descriptions_season_1 <- imdb_descriptions_raw %>%
  dplyr::filter(season == 1) %>%
  dplyr::mutate(
    episode = dplyr::case_when(
      episode == 2 ~ 1,
      episode == 3 ~ 2,
      episode == 4 ~ 3,
      episode == 5 ~ 4,
      episode == 6 ~ 5,
      episode == 7 ~ 6,
      episode == 8 ~ 7,
      episode == 9 ~ 8,
      episode == 10 ~ 9,
      episode == 11 ~ 10,
      episode == 12 ~ 11,
      episode == 13 ~ 12,
      episode == 14 ~ 13,
      episode == 15 ~ 14,
      episode == 16 ~ 15,
      episode == 17 ~ 16,
      episode == 18 ~ 17,
      episode == 19 ~ 18,
      episode == 20 ~ 19,
      episode == 21 ~ 20,
      episode == 22 ~ 21,
    )
  )



imdb_descriptions_season_2_to_7 <- imdb_descriptions_raw %>%
  dplyr::filter(season != 1)



imdb_descriptions <- imdb_descriptions_season_1 %>%
  dplyr::bind_rows(imdb_descriptions_season_2_to_7) %>%
  ## create column index
  dplyr::mutate(index = 1:153,
                description = stringr::str_remove(description, "\n")) %>%
  dplyr::select(-c(season, episode))



gilmoregirls_info <- wikitable_raw %>%
  dplyr::mutate(
    title = stringr::str_remove(title, '"'),
    title = stringr::str_remove(title, '".*'),
    air_date = stringr::str_remove(air_date, "\\(.*"),
    air_date = stringr::str_trim(air_date),
    air_date = linelist::guess_dates(air_date),
    us_views_millions = stringr::str_remove(us_views_millions, "\\[.*"),
    us_views_millions = as.numeric(us_views_millions)
  ) %>%
  dplyr::left_join(imdb_ratings, by = "index") %>%
  dplyr::left_join(imdb_descriptions, by = "index") %>%
  dplyr::relocate(season, .after = index) %>%
  tibble::tibble()




usethis::use_data(gilmoregirls_info, overwrite = TRUE)
