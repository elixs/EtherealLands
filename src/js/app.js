web3js = require('web3')

App = {
  web3Provider: null,
  contracts: {},
  ELands: null,

  init: function () {
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
    // $.getJSON('ELands.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      // var EOwnershipArtifact = data;
      var ELandsArtifact = data;
      console.log(data)
      // App.contracts.EOwnership = TruffleContract(EOwnershipArtifact);
      App.ELands = TruffleContract(ELandsArtifact);
      // App.ELands = TruffleContract({abi: "etherealLands_abi.json", address: 0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d});

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
    $(document).on('click', '.btn-create-seed', App.createRandomSeed);
    $(document).on('click', '.btn-new-land', App.createLand);
    $(document).on('click', '.btn-plant', App.seedPlanting);
    $(document).on('click', '.btn-water', App.seedWatering);
    $(document).on('click', '.btn-sleep', App.goToBed);
    $(document).on('click', '.btn-sleep-earlier', App.goToBedEarlier);
  },

  updateInterface: function () {
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
        ELandsInstance = instance;
        return ELandsInstance.getSeedsByOwner(account, {
          from: account
        }).then(function (result) {
          console.log('seeds', result);
          return App.displaySeeds(result);
        });
        //ELandsInstance.seeds(0).then(function (result) { console.log('result', result) });
      });
    });
  },

  displaySeeds: function (ids) {
    // Check if the user has a player

    // new-land


    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
        ELandsInstance = instance;



        console.log('ids', ids);

        var seedsRow = $('#seedsRow');
        var seedTemplate = $('#seedTemplate');

        $("#seedsRow").empty();
        console.log('Seeds empty');
        return ELandsInstance.ownerPlayer(account).then(function (player) {
          console.log('player', player);
          if (player == 0) {
            console.log('no-player');
            $('#new-land').show();
            return;
          }
          else {
            return ELandsInstance.players(parseInt(player) - 1).then(function (name) {
              console.log('result[0]', name);
              $('#land-name').text(name[0] + " (· - ·)º");
              $('#land-name-display').show();

              for (let id of ids) {
                // Look up seed details from our contract.Returns a`seed` object
                var seedPromise = ELandsInstance.seeds(id);
                var typePromise = ELandsInstance.getType(id);
                Promise.all([seedPromise, typePromise]).then(function ([seed, type]) {
                  console.log('seeeed', seed);
                  seedTemplate.find('.card-header').text(seed[0]);
                  seedTemplate.find('.seed-traits').text(seed[1]);
                  seedTemplate.find('.seed-plant').text(seed[2]);
                  seedTemplate.find('.seed-water').text(seed[3]);
                  seedTemplate.find('.btn-plant').attr('data-id', id);
                  seedTemplate.find('.btn-water').attr('data-id', id);
                  seedTemplate.find('img').attr('src', 'images/' + type + '.png');
                  seedsRow.append(seedTemplate.html());
                  return // something using both resultA and resultB
                });
              }
            });
          }
        });
      });
    });
  },

  createLand: function (event) {
    event.preventDefault();
    console.log('validity', $("#form")[0].checkValidity());
    if (!$("#form")[0].checkValidity()) {
      $("#form").find("#submit-hidden").click();
      return;
    }
    $("#txStatus").text("Creating new land on the blockchain. This may take a while...");
    let land_name = $(".new-land").val();
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.createLand(land_name).then(function (instance) {
        $("#txStatus").text("Successfully created land (/· - ·)/");
        return App.updateInterface();
      }).catch(function (error) {
        console.log(error.message);
        $("#txStatus").text(error.message);
      });
    });
  },

  createRandomSeed: function (event) {
    event.preventDefault();
    $("#txStatus").text("Creating new seed on the blockchain. This may take a while...");
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.getTotalSeeds().then(function (seedId) {
        ELandsInstance.createRandomSeed(seedId).then(function (seed) {
          // TODO esto se está llamando antes de tiempo
          $("#txStatus").text("Successfully created Seed " + seedId + "!");
          return App.updateInterface();
        }).catch(function (error) {
          console.log(error.message);
          $("#txStatus").text(error.message);
        });
      });
    });
  },

  seedPlanting: function (event) {
    event.preventDefault();
    let seedId = parseInt($(event.target).data('id'));
    console.log('SeedId', seedId);
    $("#txStatus").text("Planting seed on the blockchain. This may take a while...");
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.seedPlanting(seedId).then(function (result) {
        $("#txStatus").text("Successfully planted Seed " + seedId + "!");
        return App.updateInterface();
      }).catch(function (error) {
        console.log(error.message);
        $("#txStatus").text(error.message);
      });
    });
  },

  seedWatering: function (event) {
    event.preventDefault();
    let seedId = parseInt($(event.target).data('id'));
    console.log('SeedId', seedId);
    $("#txStatus").text("Watering seed on the blockchain. This may take a while...");
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.seedWatering(seedId).then(function (result) {
        $("#txStatus").text("Successfully watered Seed " + seedId + "!");
        return App.updateInterface();
      }).catch(function (error) {
        console.log(error.message);
        $("#txStatus").text(error.message);
      });
    });
  },

  goToBed: function (event) {
    event.preventDefault();
    $("#txStatus").text("Going to bed ...");
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.goToBed().then(function (result) {
        $("#txStatus").text("Successfully sleep!");
        return App.updateInterface();
      }).catch(function (error) {
        console.log(error.message);
        $("#txStatus").text(error.message);
      });
    });
  },

  goToBedEarlier: function (event) {
    event.preventDefault();
    $("#txStatus").text("Going to bed earlier...");
    return App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
      ELandsInstance = instance;
      return ELandsInstance.goToBedEarlier({
        // value: web3js.utils.toWei("0.001", "ether")
        value: 1000000000000000
      }).then(function (result) {
        $("#txStatus").text("Successfully sleep!");
        return App.updateInterface();
      }).catch(function (error) {
        console.log(error.message);
        $("#txStatus").text(error.message);
      });
    });
  },

  getSeedDetails: function (id) {
    App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
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

    App.ELands.at("0x198c884EA858f04d6CFa7D4A02aA21dE1a4C130d").then(function (instance) {
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