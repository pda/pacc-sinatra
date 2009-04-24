namespace :thin do

  desc 'Start thin webserver'
  task :start do
    puts `thin -C config.yml -R config.ru -s 2 start`
  end

  desc 'Stop thin webserver'
  task :stop do
    puts `thin -C config.yml -s 2 stop`
  end

  desc 'Restart thin webserver'
  task :restart do
    puts `thin -C config.yml -s 2 restart`
  end

end
