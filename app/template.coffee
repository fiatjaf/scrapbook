React = require 'lib/react'
Scrapbook = require 'app/Home'

{getPathParts, getHasRewrite, getBasePath, getQuickBasePath, getProtocol} = require 'lib/utils'

module.exports = (data, req, ddoc) ->
  """
  <!DOCTYPE html>
  
  <title>Scrapbook</title>
  
  <div id="scrapboard-main">
    #{React.renderComponentToString Scrapbook(data)}
  </div>
  
  <script> window.data = #{toJSON data} </script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/lazyload/2.0.3/lazyload-min.js"></script>
  <script>
    pathParts = (#{getPathParts.toString()})(location.pathname)
    hasRewrite = (#{getHasRewrite.toString()})(pathParts)
    basePath = (#{getBasePath.toString()})(pathParts, hasRewrite)

    if (hasRewrite) {
      LazyLoad.js(basePath + '_rewrite/bundle.js')
      LazyLoad.css(basePath + '_rewrite/style.css')
    }
    else {
      LazyLoad.js(basePath + '/bundle.js')
      LazyLoad.css(basePath + '/style.css')
    }
  </script>

  <script>
    #{if ddoc.settings and ddoc.settings.hashcash then "window.use_hashcash = true" else ''}
  </script>
  """
