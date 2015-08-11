module Lita
  module Handlers
    class Applause < Handler

      IMAGES = [
        'http://assets0.ordienetworks.com/images/GifGuide/clapping/Kurtclapping.gif',
        'http://assets0.ordienetworks.com/images/GifGuide/clapping/riker.gif',
        'http://assets0.ordienetworks.com/images/GifGuide/clapping/hp3.gif',
        'http://assets0.ordienetworks.com/images/GifGuide/clapping/dwight.gif',
        'http://i.imgur.com/t8zvc.gif',
        'http://i.imgur.com/5zKXz.gif',
        'http://www.animateit.net/data/media/july2012/clap-animated-animation-clap-000340-large.gif',
        'http://i.imgur.com/9Zv4V.gif',
        'http://assets0.ordienetworks.com/images/GifGuide/clapping/1292223254212-dumpfm-mario-Obamaclap.gif',
        'http://sunglasses.name/gif/joker-clap.gif',
        'http://www.reactiongifs.com/wp-content/uploads/2013/01/applause.gif'
        ]
      route(/^(applau(d|se)|bravo|slow clap)/i, :applause, command: false, help: {
        'applause' => 'Sends image of applause.'
      })

      def applause(response)
        response.reply IMAGES.sample
      end
    end

    Lita.register_handler(Applause)
  end
end
