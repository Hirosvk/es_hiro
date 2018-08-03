
[Resource, Note, User].each { |m| m.__elasticsearch__.delete_index! rescue nil}
[Resource, Note, User].each { |m| m.__elasticsearch__.create_index! }
languages = ['romulan', 'klingon', 'vulcan']

resources = []
30.times do
  resources << Resource.create!(
    title: Faker::FamousLastWords.last_words,
    body: LiterateRandomizer.paragraphs(paragraphs: 5),
    language: languages.sample
  )
end

1000.times do
  user = User.create!(
    firstname: Faker::FunnyName.name.split(' ')[0],
    lastname: Faker::FunnyName.name.split(' ')[1],
    gender: ['M', 'F'].sample,
    age: (18..100).to_a.sample,
    bio: Faker::MichaelScott.quote,
    language: languages.sample
  )

  rand(5).times do
    Note.create!(
      owner: resources.select{|r| r.language == user.language}.sample,
      body: LiterateRandomizer.paragraph,
      language: user.language,
      user_id: user.id)
  end
end
