{ yants, root }:
with (yants "configs");
{
  pop = openStruct root.configs.structAttrs.pop;
}
