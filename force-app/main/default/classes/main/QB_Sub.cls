public inherited sharing class QB_Sub implements QB_Part {
    private QB builder;
    private QB_Binder binder;

    public static QB_Sub subQueryWithBinder(QB_Binder binder) {
        return new QB_Sub(binder);
    }

    private QB_Sub(QB_Binder binder) {
        this.binder = binder;
    }

    // From

    public QB_Sub of(String ofObject) {
        builder = new QB(ofObject);
        return this;
    }

    // Fields

    public QB_Sub fields(List<sObjectField> fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields) {
        builder.fields.retrive(relationshipPath, fields);
        return this;
    }

    // Where

    public QB_Sub whereAre(QB_ConditionClause conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    // Order By - ASC, NULLS FIRST by default

    public QB_Sub orderBy(sObjectField field) {
        builder.orderBys.add(field);
        return this;
    }

    public QB_Sub orderByRelated(String path, sObjectField field) {
        builder.orderBys.add(path, field);
        return this;
    }

    public QB_Sub sortDesc() {
        builder.orderBy.sortDesc();
        return this;
    }

    public QB_Sub nullsLast() {
        builder.orderBy.nullsLast();
        return this;
    }

    // Limit

    public QB_Sub setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public QB_Sub setOffset(Integer startingRow) {
        builder.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public QB_Sub forReference() {
        builder.soqlFor.forReference();
        return this;
    }

    public QB_Sub forView() {
        builder.soqlFor.forView();
        return this;
    }

    // Build

    public String build() {
        return builder.build();
    }
}