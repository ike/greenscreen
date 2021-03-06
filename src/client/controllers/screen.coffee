###
Copyright (c) 2014, Groupon
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.###

angular.module("GScreen").controller "Screen", ($scope, $sce, $location, Channel, sockets) ->
  id = $location.url().match(/\/channels\/([^\/\?]+)/)[1]

  $scope.channel = Channel.get id
  $scope.channel.$promise.then (channel) ->
    setTimeout rotateMainContentUrl, 0

  sockets.on "channel-updated", (channel) ->
    if channel.id == $scope.channel.id
      $scope.channel = channel
      setTimeout rotateMainContentUrl, 0

  mainContentUrlCounter = 0
  lastTimeoutId = null
  rotateMainContentUrl = (counter) ->
    clearTimeout lastTimeoutId
    cell = $scope.channel.cells[0]
    urls = cell.urls
    mainContentUrlCounter = counter if counter?
    if urls.length == 1
      $scope.mainContentUrl = $sce.trustAsResourceUrl(urls[0].url)
    else
      if urls[mainContentUrlCounter].duration? && parseInt urls[mainContentUrlCounter].duration
        seconds = parseInt urls[mainContentUrlCounter].duration, 10
      else
        seconds = parseInt cell.duration, 10
      $scope.mainContentUrl = $sce.trustAsResourceUrl(urls[mainContentUrlCounter].url)
      console.log mainContentUrlCounter, seconds
      mainContentUrlCounter++
      mainContentUrlCounter = 0 if mainContentUrlCounter >= urls.length
      lastTimeoutId = setTimeout rotateMainContentUrl, seconds * 1000
    $scope.$apply() unless $scope.$$phase
