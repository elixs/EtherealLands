App = {
  web3Provider: null,
  contracts: {},
  ELands: null,

  init: function () {
    // Load pets.
    // $.getJSON('../pets.json', function(data) {
    //   var petsRow = $('#petsRow');
    //   var petTemplate = $('#petTemplate');

    //   for (i = 0; i < data.length; i ++) {
    //     petTemplate.find('.panel-title').text(data[i].name);
    //     petTemplate.find('img').attr('src', data[i].picture);
    //     petTemplate.find('.pet-breed').text(data[i].breed);
    //     petTemplate.find('.pet-age').text(data[i].age);
    //     petTemplate.find('.pet-location').text(data[i].location);
    //     petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

    //     petsRow.append(petTemplate.html());
    //   }
    // });
    // getSeedsByOwner(userAccount).then(displaySeeds);
    return App.initWeb3();
  },

  initWeb3: function () {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function () {
    $.getJSON('EOwnership.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      // var EOwnershipArtifact = data;
      var ELandsArtifact = data;
      // App.contracts.EOwnership = TruffleContract(EOwnershipArtifact);
      App.ELands = TruffleContract(ELandsArtifact);

      // Set the provider for our contract
      // App.contracts.EOwnership.setProvider(App.web3Provider);
      App.ELands.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      // return App.markAdopted();

      App.updateInterface();
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    // $(document).on('click', '.btn-adopt', App.handleAdopt);
    $(document).on('click', '.btn-createSeed', App.createRandomSeed);
  },

  updateInterface: function () {
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.ELands.deployed().then(function (instance) {
        ELandsInstance = instance;
        ELandsInstance.getSeedsByOwner(account, {
          from: account
        }).then(function (result) {
          App.displaySeeds(result);
        });
        //ELandsInstance.seeds(0).then(function (result) { console.log('result', result) });
      });
    });
  },

  markAdopted: function (adopters, account) {
    var adoptionInstance;

    App.contracts.Adoption.deployed().then(function (instance) {
      adoptionInstance = instance;

      return adoptionInstance.getAdopters.call();
    }).then(function (adopters) {
      for (i = 0; i < adopters.length; i++) {
        if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
        }
      }
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  // handleAdopt: function (event) {
  //   event.preventDefault();

  //   var petId = parseInt($(event.target).data('id'));

  //   var adoptionInstance;

  //   web3.eth.getAccounts(function (error, accounts) {
  //     if (error) {
  //       console.log(error);
  //     }

  //     var account = accounts[0];

  //     App.contracts.Adoption.deployed().then(function (instance) {
  //       adoptionInstance = instance;

  //       // Execute adopt as a transaction by sending account
  //       return adoptionInstance.adopt(petId, { from: account });
  //     }).then(function (result) {
  //       return App.markAdopted();
  //     }).catch(function (err) {
  //       console.log(err.message);
  //     });
  //   });
  // },

  displaySeeds: function (ids) {
    App.ELands.deployed().then(function (instance) {
      ELandsInstance = instance;
      console.log('ids', ids);

      var seedsRow = $('#seedsRow');
      var seedTemplate = $('#seedTemplate');

      $("#seeds").empty();
      for (id of ids) {
        // Look up seed details from our contract. Returns a `seed` object

        ELandsInstance.seeds(id)
          .then(function (seed) {
            console.log('seed', seed);
            // Using ES6's "template literals" to inject variables into the HTML.
            // Append each one to our #seeds div

            seedTemplate.find('.card-header').text(seed[0]);
            // petTemplate.find('img').attr('src', data[i].picture);
            seedTemplate.find('.seed-traits').text(seed[1]);
            seedTemplate.find('.seed-plant').text(seed[2]);
            seedTemplate.find('.seed-water').text(seed[3]);

            seedsRow.append(seedTemplate.html());
          });
      }
    });
  },

  createRandomSeed: function (event) {
    event.preventDefault();
    // This is going to take a while, so update the UI to let the user know
    // the transaction has been sent
    $("#txStatus").text("Creating new seed on the blockchain. This may take a while...");



    App.ELands.deployed().then(function (instance) {
      ELandsInstance = instance;

      //var seedId = parseInt($(event.target).data('id'));
      // var seedId = ELandsInstance.seeds.length;
      return ELandsInstance.getTotalSeeds().then(function (seedId) {
        console.log('seedId', seedId);
        ELandsInstance.createRandomSeed(seedId).then(function (seed) {
          // TODO esto se está llamando antes de tiempo
          console.log('seed', seed);
          $("#txStatus").text("Successfully created " + seed[0] + "!");
          // Transaction was accepted into the blockchain, let's redraw the UI
          App.updateInterface();
        });
      });
    });

    // return etherealLands.methods.createRandomSeed(name)
    //   .send({ from: userAccount })
    //   .on("receipt", function (receipt) {
    //     $("#txStatus").text("Successfully created " + name + "!");
    //     // Transaction was accepted into the blockchain, let's redraw the UI
    //     getSeedsByOwner(userAccount).then(displaySeeds);
    //   })
    //   .on("error", function (error) {
    //     // Do something to alert the user their transaction has failed
    //     $("#txStatus").text(error);
    //   });
  },

  seedPlanting: function (seedId) {
    // This is going to take a while, so update the UI to let the user know
    // the transaction has been sent
    $("#txStatus").text("Planting seed on the blockchain. This may take a while...");
    // Send the tx to our contract:seedId
    return etherealLands.methods.seedPlanting(seedId)
      .send({
        from: userAccount
      })
      .on("receipt", function (receipt) {
        $("#txStatus").text("Successfully planted " + receipt + "!");
        // Transaction was accepted into the blockchain, let's redraw the UI
        getSeedsByOwner(userAccount).then(displaySeeds);
      })
      .on("error", function (error) {
        // Do something to alert the user their transaction has failed
        $("#txStatus").text(error);
      });
  },

  seedWatering: function (seedId) {
    // This is going to take a while, so update the UI to let the user know
    // the transaction has been sent
    $("#txStatus").text("Watering seed on the blockchain. This may take a while...");
    // Send the tx to our contract:seedId
    return etherealLands.methods.seedWatering(seedId)
      .send({
        from: userAccount
      })
      .on("receipt", function (receipt) {
        $("#txStatus").text("Successfully planted " + receipt + "!");
        // Transaction was accepted into the blockchain, let's redraw the UI
        getSeedsByOwner(userAccount).then(displaySeeds);
      })
      .on("error", function (error) {
        // Do something to alert the user their transaction has failed
        $("#txStatus").text(error);
      });
  },

  goToBedEarlier: function () {
    $("#txStatus").text("Going to bed earlier...");
    return etherealLands.methods.goToBedEarlier()
      .send({
        from: userAccount,
        value: web3js.utils.toWei("0.001", "ether")
      })
      .on("receipt", function (receipt) {
        $("#txStatus").text("A new day has arrived!");
      })
      .on("error", function (error) {
        $("#txStatus").text(error);
      });
  },

  getSeedDetails: function (id) {
    App.ELands.deployed().then(function (instance) {
      ELandsInstance = instance;

      // Execute adopt as a transaction by sending account
      return ELandsInstance.seeds(id);
    });
  },

  seedOwner: function (id) {
    return etherealLands.methods.seedOwner(id).call()
  },

  getSeedsByOwner: function (owner) {
    console.log('Owner:', owner);

    App.ELands.deployed().then(function (instance) {
      ELandsInstance = instance;

      // Execute adopt as a transaction by sending account
      return ELandsInstance.getSeedsByOwner(owner);
    });
  }
};

$(function () {
  $(window).on('load', function () {
    App.init();
  });
});