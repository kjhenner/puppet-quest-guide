# What's in a resource?

describe "Task 1:" do
  it 'Inspect the /var/www/html/hello_puppet.html file' do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+resource\s+file\s+\/var\/www\/html\/hello_puppet\.html/
  end
end

# Mind over matter
describe "Task 2:" do
  it 'Use the resource tool to create /var/www/html/hello_puppet.html' do
    file('/var/www/html/hello_puppet.html')
      .should be_file
  end
end

# Manifest reality
describe "Task 3:" do
  it 'Create the hello_puppet.pp manifest' do
    file('/root/hello_puppet.pp')
      .should match /resource\s*{\s*\'\/var\/www\/html\/quest\/hello_puppet\.html\':\s+ensure\s*=>\s*file,\s+content\s*=>\s*\"\w+"\s+}/
  end
end

describe "Task 4:" do
  it 'Give the galatea user the comment Galatea of Cyprus' do
    file('/root/.bash_history')
      .content
      .should match /puppet\\s\s\s\s\s\s\s\s\s\s++apply\s+hello_puppet\.pp/
  end
end
