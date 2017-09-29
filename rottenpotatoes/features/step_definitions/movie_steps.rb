# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  Movie.count.should be n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  expect(page.body).to have_content(/#{e1}.*#{e2}/m)
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  ratings = rating_list.split(", ")
  ratings.each do |rating|
    if uncheck
      steps %Q{
        When I uncheck "ratings_#{rating}"
      }
    else
      steps %Q{
        When I check "ratings_#{rating}"
      }
    end
  end
end

Then /I should see all movies with the following ratings: (.*)/ do |rating_list|
  ratings = rating_list.split(", ")
  ratings.each do |rating|
    movies = Movie.where(rating: rating)
    movies.each do |movie|
        steps %Q{
          Then I should see "#{movie.title}"
        }
    end
  end
end

Then /I should not see all movies with the following ratings: (.*)/ do |rating_list|
  ratings = rating_list.split(", ")
  ratings.each do |rating|
    movies = Movie.where(rating: rating)
    movies.each do |movie|
        steps %Q{
          Then I should not see "#{movie.title}"
        }
    end
  end
end

Then /I should see all the movies/ do
  # Make sure that all the movies in the app are visible in the table
  all_movies = Movie.all
  all_movies.each do |movie|
    steps %Q{
      Then I should see "#{movie.title}"
    }
  end
end

Then /I should see the movies sorted (.*)/ do |sort_value|
  if sort_value == 'alphabetically'
    movies = Movie.all.order(:title)
  elsif sort_value == 'by release date'
    movies = Movie.all.order(:release_date)
  end
  movies.each do |movie1|
    movies.each do |movie2|
      if sort_value == 'alphabetically'
        comparison = movie1.title <=> movie2.title
      elsif sort_value == "by release date"
        comparison = movie1.release_date <=> movie2.release_date
      end
      if comparison == -1
        steps %Q{
          Then I should see "#{movie1.title}" before "#{movie2.title}"
        }
      elsif comparison == 1
        steps %Q{
          Then I should see "#{movie2.title}" before "#{movie1.title}"
        }
      end
    end
  end
end