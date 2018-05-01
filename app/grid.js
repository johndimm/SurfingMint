  function initGrid(data) {
 
    $("#jsGrid").jsGrid({
        width: "100%",
        height: "100%",

        autoload: true,
        sorting: true,
 
        data: data,
 
        fields: [
            { name: "Date", type: "text", validate: "required", width:8 },
            { name: "Amount", type: "number", width:3 },
            { name: "Description", type: "text", width:16 },
            { name: "Account Name", type: "text", width:20}
        ]
    });

    $("#jsGrid").jsGrid("sort", { field: "Amount", order: "desc" });
}
