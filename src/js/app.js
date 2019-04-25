App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    // Load pets.
    $.getJSON('../elections.json', function(data) {
      var electionsRow = $('#electionsRow');
      var electionsTemplate = $('#electionsTemplate');

      for (i = 0; i < data.length; i ++) {
        electionsTemplate.find('.id').text(data[i].id);
        electionsTemplate.find('.name').text(data[i].name);
        electionsTemplate.find('.boolean').text(data[i].boolean);

        electionsRow.append(electionsTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers... 
    if(window.ethereum) {
      App.web3Provider = window.ethereum; 
      try {
        // Request account access
        await window.ethereum.enable(); 
      } catch (error) {
        // User denied account access... 
        console.error("User denied account access"); 
      }
    }

    // Legacy dapp Browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider; 
    }
    // If no injected web3 instance is detected, fall back to ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545'); 
    }
    web3 = new Web3(App.web3Provider); 

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Elect.json', function(data) {
      // Get the ncessary contrct artifact file and instantiate it with truffle-contract
      var ElectedArtifact = data; 
      App.contracts.Elect = TruffleContract(ElectedArtifact); 

      // set the provider for our contract
      App.contracts.Elect.setProvider(App.web3Provider); 

      // Use our contract to retrieve and mar the adopted pets
      return App.markElected(); 
    }); 

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-elect', App.handleElect);
  },

  markElected: function(voters, account) {
    var electionInstance; 

    App.contracts.Elect.deployed().then(function(instance) {
      electionInstance = instance; 
      return electionInstance.getVoters.call(); 
    }).then(function(voters) {
      for(i = 0; i < voters.length; i++) {
        if(voters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.id').eq(i).find('button').text('Success').attr('disabled', true); 
        }
      }
    }).catch(function(err) {
      console.log(err.message); 
    }); 
  },

  handleElect: function(event) {
    event.preventDefault();

    var electionId = parseInt($(event.target).data('id'));

    var electedInstance; 

    web3.eth.getAccounts(function(error, accounts) {
      if(error) {
        console.log(error); 
      }

      var account = accounts[0]; 

      App.contracts.Elect.deployed().then(function(instance) {
        electedInstance = instance; 

        // Execute adopt as a transaction by sending account
        return electedInstance.elect(electionId, {from: account}); 
      }).then(function(result) {
        return App.markElected(); 
      }).catch(function(err) {
        console.log(err.message); 
      }); 
    }); 
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
