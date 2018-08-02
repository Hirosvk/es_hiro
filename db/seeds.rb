
[Resource, Note, User].each { |m| m.__elasticsearch__.delete_index! rescue nil}
[Resource, Note, User].each { |m| m.__elasticsearch__.create_index! }

resources = []
30.times do
  resources << Resource.create!(
    title: Faker::FamousLastWords.last_words,
    body: LiterateRandomizer.paragraphs(paragraphs: 5)
  )
end

1000.times do
  user = User.create!(
    firstname: Faker::FunnyName.name.split(' ')[0],
    lastname: Faker::FunnyName.name.split(' ')[1],
    gender: ['M', 'F'].sample,
    age: (18..100).to_a.sample,
    bio: LiterateRandomizer.sentence
  )

  rand(5).times do
    Note.create!(
      owner: resources.sample,
      body: LiterateRandomizer.paragraph,
      user_id: user.id)
  end
end
