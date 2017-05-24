/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#include <functional>
#include <set>
#include <string>

#include <osquery/system.h>

#include "osquery/core/conversions.h"
#include "osquery/tables/system/hash.h"

#include <sqlite3.h>

namespace osquery {

static void carveSqliteValue(sqlite3_context* ctx,
                             int argc,
                             sqlite3_value** argv) {
  if (argc == 0) {
    return;
  }

  if (SQLITE_NULL == sqlite3_value_type(argv[0])) {
    sqlite3_result_null(ctx);
    return;
  }

  // Parse and verify the split input parameters.
  std::string path((char*)sqlite3_value_text(argv[0]));
  std::set<std::string> paths = {path};

  carvePaths(paths);
  sqlite3_result_text(
      ctx, path.c_str(), static_cast<int>(path.size()), SQLITE_TRANSIENT);
}

void registerOperationExtensions(sqlite3* db) {
  sqlite3_create_function(
      db, "carve", 1, SQLITE_UTF8, nullptr, carveSqliteValue, nullptr, nullptr);
}
}