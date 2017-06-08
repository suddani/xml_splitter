describe XmlSplitter::Splitter do
  it "saves data in a zip" do
    subject.save("Test")
    subject.close_stream
  end
end
