(function() {
  var Failure, Success, isArray, isObject, listSequence, map, mapValues, nativeTypeValidator, objectSequence, objectWithProperty, pairs, pairsToObject, types, _ref, _ref1;

  _ref = require('lodash'), pairs = _ref.pairs, map = _ref.map, mapValues = _ref.mapValues;

  _ref1 = require('data.validation'), Success = _ref1.Success, Failure = _ref1.Failure;

  objectSequence = function(nameValidationPairs) {
    var failures, name, result, validation;
    failures = [];
    result = (function() {
      var _i, _len, _ref2, _results;
      _results = [];
      for (_i = 0, _len = nameValidationPairs.length; _i < _len; _i++) {
        _ref2 = nameValidationPairs[_i], name = _ref2[0], validation = _ref2[1];
        _results.push(validation.fold(function(failure) {
          failures.push(failure);
          return [name, null];
        }, function(success) {
          return [name, success];
        }));
      }
      return _results;
    })();
    if (failures.length > 0) {
      return Failure(failures);
    } else {
      return Success(pairsToObject(result));
    }
  };

  pairsToObject = function(pairs) {
    var key, result, value, _i, _len, _ref2;
    result = {};
    for (_i = 0, _len = pairs.length; _i < _len; _i++) {
      _ref2 = pairs[_i], key = _ref2[0], value = _ref2[1];
      result[key] = value;
    }
    return result;
  };

  listSequence = function(list) {
    var failures, result, validation;
    failures = [];
    result = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        validation = list[_i];
        _results.push(validation.fold(function(failure) {
          failures.push(failure);
          return null;
        }, function(success) {
          return success;
        }));
      }
      return _results;
    })();
    if (failures.length > 0) {
      return Failure(failures);
    } else {
      return Success(result);
    }
  };

  objectWithProperty = function(name) {
    return function(value) {
      var object;
      object = {};
      object[name] = value;
      return object;
    };
  };

  nativeTypeValidator = function(type) {
    return function(input) {
      if (typeof input === type) {
        return Success(input);
      } else {
        return Failure(["Input was not of type " + type]);
      }
    };
  };

  isArray = function(input) {
    return (Object.prototype.toString.call(input)) === '[object Array]';
  };

  isObject = function(input) {
    return (Object.prototype.toString.call(input)) === '[object Object]';
  };

  module.exports = types = {
    Any: function(input) {
      if (input != null) {
        return Success(input);
      } else {
        return Failure(["Input was undefined"]);
      }
    },
    OneOf: function(types) {
      return function(input) {
        var fail, type, validation, _i, _len;
        fail = Failure([]);
        for (_i = 0, _len = types.length; _i < _len; _i++) {
          type = types[_i];
          validation = type(input);
          if (validation.isSuccess) {
            return validation;
          } else {
            fail = fail.ap(validation);
          }
        }
        return fail;
      };
    },
    String: nativeTypeValidator('string'),
    Boolean: nativeTypeValidator('boolean'),
    Number: nativeTypeValidator('number'),
    Property: function(name, type) {
      if (type == null) {
        type = types.Any;
      }
      return function(object) {
        return ((object != null ? object[name] : void 0) != null ? type(object[name]) : type(null)).leftMap(function(errors) {
          var result;
          result = {};
          result[name] = errors;
          return result;
        });
      };
    },
    Object: function(memberTypes) {
      var propertyNamesToTypes;
      propertyNamesToTypes = mapValues(memberTypes, function(type, name) {
        return types.Property(name, type);
      });
      return function(object) {
        return objectSequence(pairs(mapValues(propertyNamesToTypes, function(propertyType) {
          return propertyType(object);
        })));
      };
    },
    List: function(type) {
      return function(list) {
        var value;
        if (!isArray(list)) {
          return Failure(['Input was not an array']);
        } else {
          return listSequence((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = list.length; _i < _len; _i++) {
              value = list[_i];
              _results.push(type(value));
            }
            return _results;
          })());
        }
      };
    },
    Map: function(type) {
      return function(object) {
        if (!isObject(object)) {
          return Failure(['Input was not an object']);
        } else {
          return objectSequence(pairs(mapValues(object, function(_, propertyName) {
            return types.Property(propertyName, type)(object);
          })));
        }
      };
    },
    Optional: function(type) {
      return function(input) {
        if (input != null) {
          return type(input);
        } else {
          return Success(null);
        }
      };
    },
    projections: {
      Property: function(name, type) {
        if (type == null) {
          type = types.Any;
        }
        return function(value) {
          return type(value).map(objectWithProperty(name));
        };
      }
    }
  };

}).call(this);
