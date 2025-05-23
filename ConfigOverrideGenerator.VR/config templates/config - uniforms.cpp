// Raise all uniforms maximumload to 80, restrict uniform mass to 40 at most

COG_itemCategory = "uniform";
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];
COG_finalValues = ["Supply80", 40];
COG_valueSetTypes = ["raiseTo", "lowerTo"];
COG_exceptions = ["Uniform_Base"];
COG_customFilter = {
    true
};
COG_debugLog = true;
COG_debugLimit = true;
COG_skipXLoops = 400;
COG_displayXLoops = 3;