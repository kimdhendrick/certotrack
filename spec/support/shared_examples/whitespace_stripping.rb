shared_examples 'a stripped model' do |attribute_name|
  it "should strip leading and trailing spaces from ##{attribute_name}" do
    subject.send("#{attribute_name}=", ' cat ')
    subject.save!
    subject.reload
    subject.send(attribute_name).should == 'cat'
  end
end

shared_examples 'a model that prevents duplicates' do |test_value, attribute_name|
  it "should enforce uniqueness of ##{attribute_name} when exact match" do
    subject.send("#{attribute_name}=", "#{test_value}")
    subject.should_not be_valid
    subject.errors.full_messages_for(attribute_name.to_sym).should == ["#{attribute_name.humanize} has already been taken"]
  end

  it "should enforce uniqueness of ##{attribute_name} when differ by case" do
    subject.send("#{attribute_name}=", "#{test_value.upcase}")
    subject.should_not be_valid
    subject.errors.full_messages_for(attribute_name.to_sym).should == ["#{attribute_name.humanize} has already been taken"]
  end

  it "should enforce uniqueness of ##{attribute_name} when differ by leading space" do
    subject.send("#{attribute_name}=", "   #{test_value}")
    subject.should_not be_valid
    subject.errors.full_messages_for(attribute_name.to_sym).should == ["#{attribute_name.humanize} has already been taken"]
  end

  it "should enforce uniqueness of ##{attribute_name} when differ by trailing space" do
    subject.send("#{attribute_name}=", "#{test_value}   ")
    subject.should_not be_valid
    subject.errors.full_messages_for(attribute_name.to_sym).should == ["#{attribute_name.humanize} has already been taken"]
  end
end