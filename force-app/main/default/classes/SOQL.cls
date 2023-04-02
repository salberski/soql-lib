public inherited sharing class SOQL implements Queryable {

    public static SubQuery SubQuery {
        get {
            return new SubQuery(binder);
        }
    }

    public static FiltersGroup FiltersGroup {
        get {
            return new FiltersGroup(false);
        }
    }

    public static Filter Filter {
        get {
            return new Filter(binder);
        }
    }

    public static JoinQuery InnerJoin {
        get {
            return new JoinQuery(binder);
        }
    }

    @TestVisible
    private static void setMock(String queryIdentifier, List<SObject> records) {
        mocks.put(queryIdentifier, records);
    }

    @TestVisible
    private static void setCountMock(String queryIdentifier, Integer amount) {
        countMocks.put(queryIdentifier, amount);
    }

    public interface Queryable {
        SOQL of(SObjectType ofObject);

        SOQL with(SObjectField field);
        SOQL with(List<SObjectField> fields);
        SOQL with(String fields);
        SOQL with(String relationshipName, List<SObjectField> fields);
        SOQL with(SubQuery subQuery); //SOQL.SubQuery

        SOQL count();
        SOQL countAs(SObjectField field, String alias);

        SOQL delegatedScope();
        SOQL mineScope();
        SOQL mineAndMyGroupsScope();
        SOQL myTerritoryScope();
        SOQL myTeamTerritoryScope();
        SOQL teamScope();

        SOQL whereAre(FilterClause conditions); //SOQL.FiltersGroup or SOQL.Filter

        SOQL groupBy(SObjectField field);
        SOQL groupByRollup(SObjectField field);

        SOQL orderBy(SObjectField field);
        SOQL orderByRelated(String path, SObjectField field);
        SOQL sortDesc();
        SOQL nullsLast();

        SOQL setLimit(Integer amount);

        SOQL offset(Integer startingRow);

        SOQL forReference();
        SOQL forView();
        SOQL forUpdate();
        SOQL allRows();

        SOQL systemMode();

        SOQL withSharing();
        SOQL withoutSharing();

        SOQL mocking(String queryIdentifier);

        SOQL preview();

        SOQL stripInaccessible();
        SOQL stripInaccessible(AccessType accessType);

        SObject asObject();
        List<SObject> asList();
        List<AggregateResult> asAggregated();
        Integer asInteger();
    }

    public interface SoqlSubQuery { //SOQL.SubQuery
        SubQuery of(String ofObject);

        SubQuery with(SObjectField field);
        SubQuery with(List<SObjectField> fields);
        SubQuery with(String relationshipName, List<SObjectField> fields);

        SubQuery whereAre(FilterClause conditions); //SOQL.FiltersGroup or SOQL.Filter

        SubQuery orderBy(SObjectField field);
        SubQuery orderByRelated(String relationshipName, SObjectField field);
        SubQuery sortDesc();
        SubQuery nullsLast();

        SubQuery setLimit(Integer amount);

        SubQuery offset(Integer startingRow);

        SubQuery forReference();
        SubQuery forView();
    }

    public interface SoqlFilter { //SOQL.Filter
        Filter id();
        Filter recordType();
        Filter with(SObjectField field);
        Filter with(String field);
        Filter with(String relationshipName, SObjectField field);

        Filter isNull();
        Filter isNotNull();
        Filter equal(Object value);
        Filter notEqual(Object value);
        Filter lessThan(Object value);
        Filter greaterThan(Object value);
        Filter lessThanOrEqual(Object value);
        Filter greaterThanOrEqual(Object value);
        Filter likeAny(String value);
        Filter likeAnyLeft(String value);
        Filter likeAnyRight(String value);
        Filter isIn(List<Object> inList);
        Filter isNotIn(List<Object> inList);
        Filter isIn(JoinQuery joinQuery); //SOQL.JoinQuery
        Filter isNotIn(JoinQuery joinQuery); //SOQL.JoinQuery
    }

    public interface SoqlFiltersGroup { //SOQL.FiltersGroup
        FiltersGroup add(FilterClause condition); //SOQL.Filter or SOQL.FiltersGroup
        FiltersGroup conditionLogic(String order);
    }

    public interface SoqlJoin { //SOQL.InnerJoin
        JoinQuery of(SObjectType ofObject);

        JoinQuery with(SObjectField field);

        JoinQuery whereAre(FilterClause conditions); //SOQL.Filter or SOQL.FiltersGroup
    }

    // Implementation details

    private static Binder binder;

    private QueryBuilder builder;
    private Executor executor;

    private static Map<String, List<SObject>> mocks = new Map<String, List<SObject>>();
    private static Map<String, Integer> countMocks = new Map<String, Integer>();

    public static SOQL of(SObjectType ofObject) {
        return new SOQL(ofObject);
    }

    private SOQL(SObjectType ofObject) {
        binder = new Binder();
        builder = new QueryBuilder(ofObject);
        executor = new Executor();
    }

    public SOQL with(SObjectField field) {
        builder.fields.retrive(field);
        return this;
    }

    public SOQL with(List<SObjectField> fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public SOQL with(String fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public SOQL with(String relationshipName, List<SObjectField> fields) {
        builder.fields.retrive(relationshipName, fields);
        return this;
    }

    public SOQL with(SubQuery subQuery) {
        builder.subQueries.add(subQuery);
        return this;
    }

    public SOQL count() {
        builder.fields.count();
        executor.countQuery();
        return this;
    }

    public SOQL countAs(SObjectField field, String alias) {
        builder.fields.count(field, alias);
        executor.countQuery();
        return this;
    }

    public SOQL delegatedScope() {
        builder.scope.delegated();
        return this;
    }

    public SOQL mineScope() {
        builder.scope.mine();
        return this;
    }

    public SOQL mineAndMyGroupsScope() {
        builder.scope.mineAndMyGroups();
        return this;
    }

    public SOQL myTerritoryScope() {
        builder.scope.myTerritory();
        return this;
    }

    public SOQL myTeamTerritoryScope() {
        builder.scope.myTeamTerritory();
        return this;
    }

    public SOQL teamScope() {
        builder.scope.team();
        return this;
    }

    public SOQL whereAre(FilterClause conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    public SOQL groupBy(SObjectField field) {
        builder.groupBy.with(field);
        return this;
    }

    public SOQL groupByRollup(SObjectField field) {
        builder.groupBy.rollup(field);
        return this;
    }

    public SOQL orderBy(SObjectField field) { //Order By - ASC, NULLS FIRST by default
        builder.orderBys.add(field);
        return this;
    }

    public SOQL orderByRelated(String path, SObjectField field) {
        builder.orderBys.add(path, field);
        return this;
    }

    public SOQL sortDesc() {
        builder.orderBy.sortDesc();
        return this;
    }

    public SOQL nullsLast() {
        builder.orderBy.nullsLast();
        return this;
    }

    public SOQL setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    public SOQL offset(Integer startingRow) {
        builder.soqlOffset.offset(startingRow);
        return this;
    }

    public SOQL forReference() {
        builder.soqlFor.forReference();
        return this;
    }

    public SOQL forView() {
        builder.soqlFor.forView();
        return this;
    }

    public SOQL forUpdate() {
        builder.soqlFor.forUpdate();
        return this;
    }

    public SOQL allRows() {
        builder.soqlFor.allRows();
        return this;
    }

    public SOQL systemMode() { //User Mode by default
        executor.systemMode();
        return this;
    }

    public SOQL stripInaccessible() {
        return stripInaccessible(AccessType.READABLE);
    }

    public SOQL stripInaccessible(AccessType accessType) {
        executor.stripInaccessible(accessType);
        return this;
    }

    public SOQL withSharing() { //Works only when .systemMode() enabled
        executor.withSharing();
        return this;
    }

    public SOQL withoutSharing() { //Works only when .systemMode() enabled
        executor.withoutSharing();
        return this;
    }

    public SOQL mocking(String queryIdentifier) {
        executor.mocking(queryIdentifier);
        return this;
    }

    public SOQL preview() {
        executor.preview();
        return this;
    }

    public String soql() {
        return builder.build();
    }

    public Map<String, Object> binding() {
        return binder.build();
    }

    public SObject asObject() {
        return executor.toObject(builder.build(), binder.build());
    }

    public List<SObject> asList() {
        return executor.toList(builder.build(), binder.build());
    }

    public List<AggregateResult> asAggregated() {
        return (List<AggregateResult>) asList();
    }

    public Integer asInteger() {
        return executor.toInteger(builder.build(), binder.build());
    }

    public SOQL getById(Id recordId) {
        return whereAre(Filter.id().equal(recordId));
    }

    public SOQL getByIds(List<Id> recordIds) {
        return whereAre(Filter.id().isIn(recordIds));
    }

    // Config

    public interface QueryClause {
        String build();
    }

    private class QueryBuilder implements QueryClause {
        private List<QueryClause> clauses = new QueryClause[10];

        public QueryBuilder(SObjectType ofObject) {
            this(ofObject.getDescribe().getName());
        }

        public QueryBuilder(String ofObject) {
            clauses.set(0, new QFields());
            clauses.set(2, new QFrom(ofObject));
        }

        public QFields fields {
            get {
                return (QFields) clauses[0];
            }
        }

        public QSubQueries subQueries {
            get {
                if (clauses[1] == null) {
                    clauses.set(1, new QSubQueries());
                }
                return (QSubQueries) clauses[1];
            }
        }

        public QScope scope {
            get {
                if (clauses[3] == null) {
                    clauses.set(3, new QScope());
                }
                return (QScope) clauses[3];
            }
        }

        public FiltersGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new FiltersGroup(true));
                }
                return (FiltersGroup) clauses[4];
            }
        }

        public QGroupBy groupBy {
            get {
                if (clauses[5] == null) {
                    clauses.set(5, new QGroupBy());
                }
                return (QGroupBy) clauses[5];
            }
        }

        public QOrderBy orderBy {
            get {
                return orderBys.recentOrderBy();
            }
        }

        public QOrderBys orderBys {
            get {
                if (clauses[6] == null) {
                    clauses.set(6, new QOrderBys());
                }
                return (QOrderBys) clauses[6];
            }
        }

        public QLimit soqlLimit {
            get {
                if (clauses[7] == null) {
                    clauses.set(7, new QLimit());
                }
                return (QLimit) clauses[7];
            }
        }

        public QOffset soqlOffset {
            get {
                if (clauses[8] == null) {
                    clauses.set(8, new QOffset());
                }
                return (QOffset) clauses[8];
            }
        }

        public QFor soqlFor {
            get {
                if (clauses[9] == null) {
                    clauses.set(9, new QFor());
                }
                return (QFor) clauses[9];
            }
        }

        public String build() {
            List<String> soqlParts = new List<String>();

            for (QueryClause clause : clauses) {
                if (clause == null) {
                    continue;
                }
                soqlParts.add(clause.build());
            }

            return String.join(new List<String>(soqlParts), ' ');
        }
    }

    private class QFields implements QueryClause {
        private Set<String> queryFields = new Set<String>();

        public void count() {
            queryFields.add('COUNT()');
        }

        public void count(SObjectField field, String alias) {
            queryFields.add('COUNT(' + field.getDescribe().getName() + ') ' + alias);
        }

        public void retrive(String fields) {
            for (String field : fields.deleteWhitespace().split(',')) {
                queryFields.add(field);
            }
        }

        public void retrive(List<SObjectField> fields) {
            for (SObjectField field : fields) {
                retrive(field);
            }
        }

        public void retrive(SObjectField field) {
            queryFields.add(field.getDescribe().getName());
        }

        public void retrive(String relationshipPath, List<SObjectField> fields) {
            for (SObjectField field : fields) {
                retrive(relationshipPath, field);
            }
        }

        public void retrive(String relationshipPath, SObjectField field) {
            queryFields.add(relationshipPath + '.' + field.getDescribe().getName());
        }

        public String build() {
            if (queryFields.isEmpty()) {
                return 'SELECT Id';
            }
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }
    }

    public class SubQuery implements QueryClause, SoqlSubQuery {
        private QueryBuilder builder;
        private Binder binder;

        public SubQuery(Binder binder) {
            this.binder = binder;
        }

        public SubQuery of(String ofObject) {
            builder = new QueryBuilder(ofObject);
            return this;
        }

        public SubQuery with(SObjectField field) {
            builder.fields.retrive(field);
            return this;
        }

        public SubQuery with(List<SObjectField> fields) {
            builder.fields.retrive(fields);
            return this;
        }

        public SubQuery with(String relationshipName, List<SObjectField> fields) {
            builder.fields.retrive(relationshipName, fields);
            return this;
        }

        public SubQuery whereAre(FilterClause conditions) {
            builder.conditions.add(conditions);
            return this;
        }

        public SubQuery orderBy(SObjectField field) {
            builder.orderBys.add(field);
            return this;
        }

        public SubQuery orderByRelated(String relationshipName, SObjectField field) {
            builder.orderBys.add(relationshipName, field);
            return this;
        }

        public SubQuery sortDesc() {
            builder.orderBy.sortDesc();
            return this;
        }

        public SubQuery nullsLast() {
            builder.orderBy.nullsLast();
            return this;
        }

        public SubQuery setLimit(Integer amount) {
            builder.soqlLimit.max(amount);
            return this;
        }

        public SubQuery offset(Integer startingRow) {
            builder.soqlOffset.offset(startingRow);
            return this;
        }

        public SubQuery forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public SubQuery forView() {
            builder.soqlFor.forView();
            return this;
        }

        public String build() {
            return builder.build();
        }
    }

    private class QSubQueries implements QueryClause {
        private List<SubQuery> subQueries = new List<SubQuery>();

        public void add(SubQuery subQuery) {
            subQueries.add(subQuery);
        }

        public String build() {
            List<String> subQueriesSoql = new List<String>();

            for (SubQuery sub : subQueries) {
                subQueriesSoql.add('(' + sub.build() + ')');
            }

            return ', ' + String.join(subQueriesSoql, ', ');
        }
    }

    private class QFrom implements QueryClause {
        private String objectApiName;

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    private class QScope implements QueryClause {
        private String scope = 'EVERYTHING';

        public void delegated() {
            scope = 'DELEGATED';
        }

        public void mine() {
            scope = 'MINE';
        }

        public void mineAndMyGroups() {
            scope = 'MINE_AND_MY_GROUPS';
        }

        public void myTerritory() {
            scope = 'MY_TERRITORY';
        }

        public void myTeamTerritory() {
            scope = 'MY_TEAM_TERRITORY';
        }

        public void team() {
            scope = 'TEAM';
        }

        public String build() {
            return 'USING SCOPE ' + scope;
        }
    }

    public interface FilterClause {
        String build();
    }

    public class FiltersGroup implements FilterClause, QueryClause, SoqlFiltersGroup {
        private List<FilterClause> queryConditions = new List<FilterClause>();
        private String order = '';
        private Boolean isMain = false;

        public FiltersGroup(Boolean isMain) {
            this.isMain = isMain;
        }

        public FiltersGroup add(FilterClause condition) {
            queryConditions.add(condition);
            return this;
        }

        public FiltersGroup conditionLogic(String order) {
            this.order = order;
            return this;
        }

        public String build() {
            if (String.isEmpty(order)) {
                setDefaultOrder();
            }

            if (isMain) {
                return 'WHERE ' + buildNested();
            }

            return buildNested();
        }

        private void setDefaultOrder() {
            List<String> defaultOrder = new List<String>();

            for (Integer i = 0; i < queryConditions.size(); i++) {
                defaultOrder.add(String.valueOf(i + 1));
            }

            order = String.join(defaultOrder, ' AND '); // e.g (1 AND 2 AND 3)
        }

        public String buildNested() {
            String conditions = addSpecialCharactersToOrder(order); // e.g (*1* AND (*2* OR *3*))

            for (Integer i = 0; i < queryConditions.size(); i++) {
                conditions = conditions.replace(
                    addSpecialCharacters(String.valueOf(i + 1)), // e.g *1*
                    queryConditions.get(i).build()
                );
            }

            return conditions;
        }

        private String addSpecialCharactersToOrder(String order) {
            String formattedOrder = order;

            for (Integer i = 0; i < queryConditions.size(); i++) {
                String conditionNumber = String.valueOf(i + 1);

                formattedOrder = formattedOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
            }

            if (isMain) {
                return formattedOrder;
            }

            return '(' + formattedOrder + ')'; // e.g (*1* AND (*2* OR *3*))
        }

        private String addSpecialCharacters(String condition) {
            return '*' + condition.trim() + '*';
        }
    }

    public class Filter implements FilterClause, SoqlFilter {
        private String field;
        private String comperator;
        private Object value;
        private Binder binder;
        private JoinQuery joinQuery;

        public Filter(Binder binder) {
            this.binder = binder;
        }

        public Filter id() {
            return with('Id');
        }

        public Filter recordType() {
            return with('RecordType.DeveloperName');
        }

        public Filter with(SObjectField field) {
            return with(field.getDescribe().getName());
        }

        public Filter with(String relationshipName, SObjectField field) {
            return with(relationshipName + '.' + field.getDescribe().getName());
        }

        public Filter with(String field) {
            this.field = field;
            return this;
        }

        public Filter isNull() {
            return equal(null);
        }

        public Filter isNotNull() {
            return notEqual(null);
        }

        public Filter equal(Object value) {
            return set('=', value);
        }

        public Filter notEqual(Object value) {
            return set('!=', value);
        }

        public Filter lessThan(Object value) {
            return set('<', value);
        }

        public Filter greaterThan(Object value) {
            return set('>', value);
        }

        public Filter lessThanOrEqual(Object value) {
            return set('<=', value);
        }

        public Filter greaterThanOrEqual(Object value) {
            return set('>=', value);
        }

        public Filter likeAny(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Filter likeAnyLeft(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()));
        }

        public Filter likeAnyRight(String value) {
            return set('LIKE', String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Filter isIn(List<Object> inList) {
            return set('IN', inList);
        }

        public Filter isNotIn(List<Object> inList) {
            return set('NOT IN', inList);
        }

        private Filter set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public Filter isIn(JoinQuery joinQuery) {
            return set('IN', joinQuery);
        }

        public Filter isNotIn(JoinQuery joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private Filter set(String comperator, JoinQuery joinQuery) {
            this.joinQuery = joinQuery;
            this.comperator = comperator;
            return this;
        }

        public String build() {
            if (joinQuery != null) {
                return field + ' ' + comperator + ' (' + joinQuery.build() + ')';
            }

            return field + ' ' + comperator + ' :' + binder.bind(value);
        }
    }

    public class JoinQuery implements QueryClause, SoqlJoin {
        private QueryBuilder builder;
        private Binder binder;

        public JoinQuery(Binder binder) {
            this.binder = binder;
        }

        public JoinQuery of(SObjectType ofObject) {
            builder = new QueryBuilder(ofObject);
            return this;
        }

        public JoinQuery with(SObjectField field) {
            builder.fields.retrive(field);
            return this;
        }

        public JoinQuery whereAre(FilterClause condition) {
            builder.conditions.add(condition);
            return this;
        }

        public String build() {
            return builder.build();
        }
    }

    private class QGroupBy implements QueryClause {
        private Set<String> groupByFields = new Set<String>();

        public void with(SObjectField field) {
            groupByFields.add(field.getDescribe().getName());
        }

        public void rollup(SObjectField field) {
            groupByFields.add('ROLLUP(' + field.getDescribe().getName() + ')');
        }

        public String build() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    private class QOrderBys implements QueryClause {
        public List<QOrderBy> orderBys = new List<QOrderBy>();

        public void add(SObjectField field) {
            orderBys.add(new QOrderBy().with(field));
        }

        public void add(String relationshipName, SObjectField field) {
            orderBys.add(new QOrderBy().with(relationshipName, field));
        }

        public QOrderBy recentOrderBy() {
            return orderBys.get(orderBys.size() - 1);
        }

        public String build() {
            List<String> orderFields = new List<String>();

            for (QOrderBy orderBy : orderBys) {
                orderFields.add(orderBy.build());
            }

            return 'ORDER BY ' + String.join(orderFields, ', ');
        }
    }

    private class QOrderBy implements QueryClause {
        private String orderField;
        private String sortingOrder = 'ASC';
        private String nullsOrder = 'FIRST';

        public QOrderBy with(SObjectField field) {
            orderField = field.getDescribe().getName();
            return this;
        }

        public QOrderBy with(String relationshipName, SObjectField field) {
            orderField = relationshipName + '.' + field.getDescribe().getName();
            return this;
        }

        public void sortDesc() {
            sortingOrder = 'DESC';
        }

        public void nullsLast() {
            nullsOrder = 'LAST';
        }

        public String build() {
            return orderField + ' ' + sortingOrder + ' NULLS ' + nullsOrder;
        }
    }

    private class QLimit implements QueryClause {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    private class QOffset implements QueryClause {
        private Integer soqlOffset = 2000;

        public void offset(Integer fromRow) {
            soqlOffset = fromRow;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    private class QFor implements QueryClause {
        private String forStatement;

        public void forReference() {
            forStatement = 'FOR REFERENCE';
        }

        public void forView() {
            forStatement = 'FOR VIEW';
        }

        public void forUpdate() {
            forStatement = 'FOR UPDATE';
        }

        public void allRows() {
            forStatement = 'ALL ROWS';
        }

        public String build() {
            return forStatement;
        }
    }

    private class Binder {
        private Integer bindIndex = 0;
        private Map<String, Object> binding = new Map<String, Object>();

        public String bind(Object value) {
            bindIndex++;
            binding.put('v' + bindIndex, value);

            return 'v' + bindIndex;
        }

        public Map<String, Object> build() {
            return binding;
        }
    }

    private enum SharingLevel {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    private inherited sharing class Executor {
        private SharingLevel sharingMode = SharingLevel.INHERITED;
        private AccessLevel accessMode = AccessLevel.USER_MODE; //The object permissions, field-level security, sharing rules are enforced.
        private AccessType accessType;

        private String queryIdentifier;
        private Boolean withPreview = false;
        private Boolean isCountQuery = false;

        private final Map<SharingLevel, DatabaseQuery> MODE_TO_EXECUTOR = new Map<SharingLevel, DatabaseQuery>{
            SharingLevel.WITH_SHARING => new WithSharing(),
            SharingLevel.WITHOUT_SHARING => new WithoutSharing(),
            SharingLevel.INHERITED => new InheritedSharing()
        };

        public void withSharing() {
            sharingMode = SharingLevel.WITH_SHARING;
        }

        public void withoutSharing() {
            sharingMode = SharingLevel.WITHOUT_SHARING;
        }

        public void stripInaccessible(AccessType type) {
            accessType = type;
        }

        public void systemMode() { //The object permissions, field-level permissions are ignored, sharing rules are controlled by the sharingMode.
            accessMode = AccessLevel.SYSTEM_MODE;
        }

        public void mocking(String identifier) {
            queryIdentifier = identifier;
        }

        public void countQuery() {
            isCountQuery = true;
        }

        public void preview() {
            withPreview = true;
        }

        public SObject toObject(String query, Map<String, Object> binding) {
            try {
                return toList(query, binding)[0];
            } catch (ListException e) {
                return null; //List index out of bounds: 0
            }
        }

        public Integer toInteger(String query, Map<String, Object> binding) {
            if (withPreview) {
                previewSoql(query);
                previewBinding(binding);
            }

            if (countMocks.containsKey(queryIdentifier)) {
                return countMocks.get(queryIdentifier);
            }

            return MODE_TO_EXECUTOR.get(sharingMode).executeCount(query, binding, accessMode);
        }

        public List<SObject> toList(String query, Map<String, Object> binding) {
            if (withPreview) {
                previewSoql(query);
                previewBinding(binding);
            }

            if (mocks.containsKey(queryIdentifier)) {
                return mocks.get(queryIdentifier);
            }

            if (accessType == null) {
                return MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode);
            }

            return Security.stripInaccessible(
                accessType,
                MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode)
            ).getRecords();
        }

        private void previewSoql(String query) {
            System.debug('\n\n============ SOQL Preview ============\n' + query + '\n=======================================\n');
        }

        private void previewBinding(Map<String, Object> binding) {
            System.debug('\n\n============ SOQL Binding ============\n' + JSON.serializePretty(binding) + '\n=======================================\n');
        }
    }

    private interface DatabaseQuery {
        List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel);
        Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }
}