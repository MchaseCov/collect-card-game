# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin_all_from 'app/javascript/channels', under: 'channels'
pin_all_from 'app/javascript/components', under: 'components'
pin 'htm', to: 'https://ga.jspm.io/npm:htm@3.1.0/dist/htm.module.js'
# pin 'react', to: 'https://ga.jspm.io/npm:react@18.0.0/index.js'
# pin 'react-dom', to: 'https://ga.jspm.io/npm:react-dom@18.0.0/index.js'
# pin 'process', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.21/nodelibs/browser/process-production.js'
# pin 'scheduler', to: 'https://ga.jspm.io/npm:scheduler@0.21.0/index.js'
pin 'react', to: 'https://ga.jspm.io/npm:react@18.0.0/dev.index.js'
pin 'react-dom', to: 'https://ga.jspm.io/npm:react-dom@18.0.0/dev.index.js'
pin 'process', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.21/nodelibs/browser/process.js'
pin 'scheduler', to: 'https://ga.jspm.io/npm:scheduler@0.21.0/dev.index.js'
pin 'react-dom/client', to: 'https://ga.jspm.io/npm:react-dom@18.0.0/dev.client.js'
