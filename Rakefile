namespace :thin do

  desc 'Start thin webserver'
  task :start do
    puts `thin -C config.yml -R config.ru -s 1 start`
  end

  desc 'Stop thin webserver'
  task :stop do
    puts `thin -C config.yml -s 1 stop`
  end

  desc 'Restart thin webserver'
  task :restart do
    puts `thin -C config.yml -s 1 restart`
  end

end
