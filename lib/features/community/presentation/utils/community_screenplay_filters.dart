import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../explore/domain/template_screenplay_filters.dart';

/// @deprecated Use [filterTemplateScreenplays] from explore domain.
List<Screenplay> filterCommunityScreenplays(
  List<Screenplay> source,
  int categoryIndex,
) =>
    filterTemplateScreenplays(source, categoryIndex);

/// @deprecated Use [sortTemplateScreenplays] from explore domain.
List<Screenplay> sortCommunityScreenplays(
  List<Screenplay> source,
  int sortIndex,
) =>
    sortTemplateScreenplays(source, sortIndex);
