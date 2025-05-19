//
//  Copyright 2025 Rick van Voorden and Bill Fisher
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Algorithms
import Foundation

extension Sequence {
  func min<Comparator: SortComparator>(
    count: Int,
    using comparator: Comparator
  ) -> [Element]
  where Element == Comparator.Compared {
    self.min(count: count) {
      comparator.compare($0, $1) == .orderedAscending
    }
  }
}

extension Sequence {
  func min<S: Sequence, Comparator: SortComparator>(
    count: Int,
    using comparators: S
  ) -> [Element]
  where Element == Comparator.Compared, S.Element == Comparator {
    self.min(count: count) {
      comparators.compare($0, $1) == .orderedAscending
    }
  }
}
